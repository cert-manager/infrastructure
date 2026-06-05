locals {
  cncf_project_billing_id = "010256-CB82C2-8ED6FC" # "CNCF Invoiced Billing"
}

module "cert-manager-folder" {
  source = "./modules/gcp-folder/"

  folder_display_name = "cert-manager"
  folder_id           = "585046353847"               # cert-manager folder
  folder_parent       = "organizations/782639440630" # CNCF organization
  folder_iam = {
    "roles/resourcemanager.folderAdmin"  = setunion(local.cert_manager_release_managers, ["user:hahmadzai@linuxfoundation.org"])
    "roles/resourcemanager.folderEditor" = ["user:hahmadzai@linuxfoundation.org"],
  }
}

module "cert-manager-general" {
  source = "./modules/gcp-project/"

  project_name       = "CM generic project"
  project_id         = "cert-manager-general"
  project_folder_id  = module.cert-manager-folder.folder_id
  project_billing_id = local.cncf_project_billing_id
  project_apis = toset([
    "dns.googleapis.com",
    "compute.googleapis.com",
    "pubsub.googleapis.com",
    "storage.googleapis.com",
  ])
  project_iam = {
    "roles/owner" = local.cert_manager_release_managers
    "roles/storage.admin" = setunion(
      local.cert_manager_release_managers,
      [google_service_account.booth_compute_sa.member]
    )
    "roles/dns.admin" = [
      # TODO: this service account should be mananaged by terraform
      "serviceAccount:dns01-solver@cert-manager-general.iam.gserviceaccount.com",
    ]
  }
}

module "cert-manager-release" {
  source = "./modules/gcp-project/"

  project_name       = "CM release infra"
  project_id         = "cert-manager-release"
  project_folder_id  = module.cert-manager-folder.folder_id
  project_billing_id = local.cncf_project_billing_id
  project_apis = toset([
    "cloudbuild.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "storage.googleapis.com",
  ])
  audit_configs = [
    {
      service   = "cloudkms.googleapis.com"
      log_types = ["ADMIN_READ", "DATA_READ", "DATA_WRITE"]
    },
  ]
  project_iam = {
    "roles/owner"         = local.cert_manager_release_managers
    "roles/storage.admin" = local.cert_manager_release_managers

    "roles/cloudbuild.builds.editor" = [
      # When clicking "Run" in the UI or when running `gcloud builds triggers
      # run`, the legacy Cloud Build SA is still used to trigger the run (because we have
      # these 3 Organization policies: constraints/cloudbuild.disableCreateDefaultServiceAccount,
      # constraints/cloudbuild.useComputeServiceAccount and constraints/cloudbuild.useBuildServiceAccount,
      # see https://docs.cloud.google.com/build/docs/cloud-build-service-account-updates#configure_the_default_service_account_for_an_organization for more info).
      # So we need to grant it roles/cloudbuild.builds.editor.
      "serviceAccount:${module.cert-manager-release.number}@cloudbuild.gserviceaccount.com",
    ]
    "roles/logging.logWriter" = [
      google_service_account.cert-manager-release-gcb.member,
    ]
  }
}

module "cert-manager-tests-trusted" {
  source = "./modules/gcp-project/"

  project_name       = "CM testing infra - trusted"
  project_id         = "cert-manager-tests-trusted"
  project_folder_id  = module.cert-manager-folder.folder_id
  project_billing_id = local.cncf_project_billing_id
  project_apis = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "pubsub.googleapis.com",
    "artifactregistry.googleapis.com",
    "storage.googleapis.com",
  ])
  project_iam = {
    "roles/owner"                   = local.cert_manager_release_managers
    "roles/storage.admin"           = local.cert_manager_release_managers
    "roles/logging.logWriter"       = [module.prow-cluster-trusted.worker_pool_sa_member]
    "roles/monitoring.metricWriter" = [module.prow-cluster-trusted.worker_pool_sa_member]
    # Lets each Prow controller GSA (trusted_prow_controllers.tf) auth via
    # gke-gcloud-auth-plugin; in-cluster authz is K8s RBAC.
    "roles/container.clusterViewer" = [
      for sa in google_service_account.prow-control-plane : sa.member
    ]
  }
}

module "cert-manager-tests-untrusted" {
  source = "./modules/gcp-project/"

  project_name       = "CM testing infra - untrusted"
  project_id         = "cert-manager-tests-untrusted"
  project_folder_id  = module.cert-manager-folder.folder_id
  project_billing_id = local.cncf_project_billing_id
  project_apis = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "pubsub.googleapis.com",
  ])
  project_iam = {
    "roles/owner"                   = local.cert_manager_release_managers
    "roles/logging.logWriter"       = [module.prow-cluster-untrusted.worker_pool_sa_member]
    "roles/monitoring.metricWriter" = [module.prow-cluster-untrusted.worker_pool_sa_member]
    # Lets each Prow controller GSA (trusted_prow_controllers.tf) auth via
    # gke-gcloud-auth-plugin; in-cluster authz is K8s RBAC.
    "roles/container.clusterViewer" = [
      for sa in google_service_account.prow-control-plane : sa.member
    ]
  }
}
