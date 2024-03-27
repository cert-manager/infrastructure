module "prow-cluster-trusted" {
  source = "./modules/gcp-cluster/"

  project_id          = module.cert-manager-tests-trusted.project_id
  gcp_region          = local.gcp_region
  location            = local.gke_zonal_location
  cluster_name        = "prow-trusted"
  cluster_description = "Test cluster for trusted tests"

  node_config = {
    min_count = 0
    max_count = 3

    machine_type = "n1-standard-2"
    disk_size_gb = "10"
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
    max_count = 3

    machine_type = "e2-highcpu-16"
    disk_size_gb = "150"
    disk_type    = "pd-ssd"
    preemptible  = true
  }
}
