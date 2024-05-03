# NOTE: we still have to promote the Loadbalancer IP to a static ip (see https://docs.prow.k8s.io/docs/getting-started-deploy/#configure-ssl)
# I haven't figured out yet how to do this using terraform.
module "prow-cluster-trusted" {
  source = "./modules/gcp-cluster/"

  project_id          = module.cert-manager-tests-trusted.project_id
  gcp_region          = local.gcp_region
  location            = local.gke_zonal_location
  cluster_name        = "prow-trusted"
  cluster_description = "Test cluster for trusted tests"

  cluster_enable_workload_identity = true
  cluster_enable_http_load_balancing = true

  node_config = {
    min_count = 0
    max_count = 3

    machine_type = "n1-standard-2"
    disk_size_gb = "25"
    disk_type    = "pd-ssd"
    preemptible  = false
  }
}

module "prow-cluster-untrusted" {
  source = "./modules/gcp-cluster/"

  project_id          = module.cert-manager-tests-untrusted.project_id
  gcp_region          = local.gcp_region
  location            = local.gke_zonal_location
  cluster_name        = "prow-untrusted"
  cluster_description = "Test cluster for untrusted tests"

  node_config = {
    min_count = 0
    max_count = 10

    machine_type = "e2-highcpu-16"
    disk_size_gb = "150"
    disk_type    = "pd-ssd"
    preemptible  = true
  }
}
