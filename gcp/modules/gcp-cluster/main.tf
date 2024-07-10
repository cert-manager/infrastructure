terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.24.0"
    }
  }
  required_version = ">= 1.6.1"
}

resource "google_compute_network" "network" {
  name        = "k8s-${var.cluster_name}-network"
  description = "Network for the ${var.cluster_name} GKE cluster"

  project = var.project_id

  auto_create_subnetworks = false
  mtu                     = 1500
}

resource "google_compute_subnetwork" "subnetwork" {
  name = "k8s-${var.cluster_name}-subnetwork"

  region  = var.gcp_region
  project = var.project_id
  network = google_compute_network.network.self_link

  ip_cidr_range = "172.16.0.0/24"

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.8.0.0/17"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.8.240.0/20"
  }
}

resource "google_container_cluster" "cluster" {
  name        = var.cluster_name
  description = var.cluster_description

  project  = var.project_id
  location = var.location

  enable_shielded_nodes = false
  enable_legacy_abac    = false

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "REGULAR"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "06:00"
    }
  }

  network    = google_compute_network.network.self_link
  subnetwork = google_compute_subnetwork.subnetwork.self_link

  datapath_provider = "ADVANCED_DATAPATH"

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS",
      // Control plane
      "APISERVER",
      "CONTROLLER_MANAGER",
      "SCHEDULER"
    ]
  }

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      // Control plane
      "APISERVER",
      "SCHEDULER",
      "CONTROLLER_MANAGER",
      // Kube state metrics
      "STORAGE",
      "HPA",
      "POD",
      "DAEMONSET",
      "DEPLOYMENT",
      "STATEFULSET",
      // cAdvisor and Kubelet metrics
      "KUBELET",
      "CADVISOR"
    ]
    managed_prometheus {
      enabled = true
    }
  }

  addons_config {
    http_load_balancing {
      disabled = !var.cluster_enable_http_load_balancing
    }

    horizontal_pod_autoscaling {
      disabled = true
    }

    network_policy_config {
      disabled = true
    }

    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  dynamic "workload_identity_config" {
    for_each = local.workload_pool != null ? [1] : []
    content {
      workload_pool = local.workload_pool
    }
  }

  lifecycle {
    ignore_changes = [
      min_master_version
    ]
    # prevent_destroy = "true"
  }
}

resource "google_service_account" "worker_pool_sa" {
  account_id   = "k8s-node"
  display_name = "k8s node Service Account"
  project      = var.project_id
}

resource "google_project_iam_binding" "worker_pool_sa_logWriter" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  members = [
    google_service_account.worker_pool_sa.member
  ]
}

resource "google_project_iam_binding" "worker_pool_sa_metricWriter" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  members = [
    google_service_account.worker_pool_sa.member
  ]
}

resource "google_container_node_pool" "worker_pool" {
  name = "worker-pool-001"

  project  = var.project_id
  location = var.location
  cluster  = google_container_cluster.cluster.name

  autoscaling {
    min_node_count = var.node_config.min_count
    max_node_count = var.node_config.max_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    image_type = "COS_CONTAINERD"

    gcfs_config {
      enabled = true
    }
    gvnic {
      enabled = true
    }

    machine_type = var.node_config.machine_type
    disk_size_gb = var.node_config.disk_size_gb
    disk_type    = var.node_config.disk_type
    preemptible  = var.node_config.preemptible

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.worker_pool_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    dynamic "workload_metadata_config" {
      for_each = var.cluster_enable_workload_identity ? [1] : []
      content {
        mode = "GKE_METADATA"
      }
    }
  }

  # changing initial_node_count forces recreation
  # ignore changes so that we can manually resize it without rectification on subsequent runs
  lifecycle {
    ignore_changes = [
      initial_node_count
    ]
  }
}
