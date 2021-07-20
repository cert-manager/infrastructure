provider "google" {
  region = var.region
}

module "gke_auth" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  depends_on   = [module.gke]
  project_id   = var.project_id
  location     = module.gke.location
  cluster_name = module.gke.name
}

resource "local_file" "kubeconfig" {
  content  = module.gke_auth.kubeconfig_raw
  filename = "kubeconfig_${var.env_name}"
}

module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 2.5"
  project_id   = var.project_id
  network_name = "${var.network}-${var.env_name}"
  subnets = [
    {
      subnet_name   = "${var.subnetwork}-${var.env_name}"
      subnet_ip     = "10.10.0.0/16"
      subnet_region = var.region
    },
  ]
  secondary_ranges = {
    "${var.subnetwork}-${var.env_name}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "10.20.0.0/16"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "10.30.0.0/16"
      },
    ]
  }
}

module "gke" {
  source            = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id        = var.project_id
  name              = "${var.cluster_name}-${var.env_name}"
  regional          = true
  region            = var.region
  network           = module.gcp-network.network_name
  subnetwork        = module.gcp-network.subnets_names[0]
  ip_range_pods     = var.ip_range_pods_name
  ip_range_services = var.ip_range_services_name
  node_pools = [
    {
      name           = "node-pool"
      machine_type   = "e2-medium"
      node_locations = "europe-west1-b,europe-west1-c,europe-west1-d"
      min_count      = 1
      max_count      = 2
      disk_size_gb   = 30
    },
  ]
}

# Retrieve an access token as the Terraform runner
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}

resource "helm_release" "cert-manager" {
  name             = "jetstack"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = var.cert_manager_version
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "google_compute_global_address" "ingress_global_ip" {
  name    = "ingress-ip"
  project = var.project_id
}

resource "kubernetes_deployment" "test_deployment" {
  metadata {
    name      = "test-deployment"
    namespace = "default"
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        app = "test-deployment"
      }
    }
    template {
      metadata {
        labels = {
          "app" = "test-deployment"
        }
      }
      spec {
        container {
          image = "gcr.io/google-samples/node-hello:1.0"
          name  = "hello"
          env {
            name  = "PORT"
            value = "8080"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "test_service" {
  metadata {
    name = "test-service"
  }
  spec {
    selector = kubernetes_deployment.test_deployment.spec[0].template[0].metadata[0].labels
    port {
      port        = 8080
      target_port = 8080
    }
    type = "NodePort"
  }
}

resource "kubernetes_ingress" "test_ingress" {
  metadata {
    name = "test-ingress"
    annotations = {
      "kubernetes.io/ingress.global-static-ip-name" = google_compute_global_address.ingress_global_ip.name
      "acme.cert-manager.io/http01-edit-in-place"   = "true"
    }
  }

  spec {
    backend {
      service_name = "test-service"
      service_port = 8080
    }

    rule {
      http {
        path {
          backend {
            service_name = "test-service"
            service_port = 8080
          }

          path = "/*"
        }
      }
    }

    # tls {
    #   secret_name = "tls-secret"
    #   hosts       = [trimsuffix("test-ingress.${data.google_dns_managed_zone.dns_zone.dns_name}", ".")]
    # }
  }
}

data "google_dns_managed_zone" "dns_zone" {
  name    = "k8s-careers-arsh"
  project = var.project_id
}

resource "google_dns_record_set" "ingress_record" {
  provider     = google-beta
  managed_zone = data.google_dns_managed_zone.dns_zone.name
  name         = "test-ingress.${data.google_dns_managed_zone.dns_zone.dns_name}"
  type         = "A"
  rrdatas      = [google_compute_global_address.ingress_global_ip.address]
  ttl          = 60
  project      = var.project_id
}
