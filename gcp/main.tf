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
data "google_client_config" "provider" {}
data "google_container_cluster" "my_cluster" {
  name     = "${var.cluster_name}-${var.env_name}"
  location = var.region
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.my_cluster.endpoint}"
    token                  = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
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

data "kubernetes_service" "ingress_service" {
  metadata {
    name = "ingress-gce-controller"
  }
}

data "google_dns_managed_zone" "dns_zone" {
  name = "arsh.future.k8s.careers."
}

resource "google_dns_record_set" "ingress_record" {
  provider     = "google-beta"
  managed_zone = data.google_dns_managed_zone.dns_zone.name
  name         = "*.${data.google_dns_managed_zone.dns_zone.name}"
  type         = "CNAME"
  rrdatas      = [data.kubernetes_service.ingress_service.status.0.load_balancer.0.ingress.0.hostname]
  ttl          = 60
}
