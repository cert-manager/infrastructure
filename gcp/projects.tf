locals {
  project_folder_id       = "585046353847"         # cert-manager folder
  cncf_project_billing_id = "010256-CB82C2-8ED6FC" # "CNCF Invoiced Billing"
}

module "cert-manager-general" {
  source = "./modules/gcp-project/"

  project_name       = "CM generic project"
  project_id         = "cert-manager-general"
  project_folder_id  = local.project_folder_id
  project_billing_id = local.cncf_project_billing_id
  project_owners     = local.cert_manager_release_managers
}

module "cert-manager-release" {
  source = "./modules/gcp-project/"

  project_name       = "CM release infra"
  project_id         = "cert-manager-release"
  project_folder_id  = local.project_folder_id
  project_billing_id = local.cncf_project_billing_id
  project_owners     = local.cert_manager_release_managers
  project_apis = toset([
    "cloudbuild.googleapis.com",
    "storage.googleapis.com",
    "cloudkms.googleapis.com",
  ])
}

module "cert-manager-tests-trusted" {
  source = "./modules/gcp-project/"

  project_name       = "CM testing infra - trusted"
  project_id         = "cert-manager-tests-trusted"
  project_folder_id  = local.project_folder_id
  project_billing_id = local.cncf_project_billing_id
  project_owners     = local.cert_manager_release_managers
}

module "cert-manager-tests-untrusted" {
  source = "./modules/gcp-project/"

  project_name       = "CM testing infra - untrusted"
  project_id         = "cert-manager-tests-untrusted"
  project_folder_id  = local.project_folder_id
  project_billing_id = local.cncf_project_billing_id
  project_owners     = local.cert_manager_release_managers
}
