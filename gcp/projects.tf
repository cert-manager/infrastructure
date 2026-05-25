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
    "roles/owner"                               = local.cert_manager_release_managers
    "roles/resourcemanager.projectOwnerInvitee" = local.cert_manager_release_managers_invitee
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
    "roles/owner"                               = local.cert_manager_release_managers
    "roles/resourcemanager.projectOwnerInvitee" = local.cert_manager_release_managers_invitee
    "roles/storage.admin"                       = local.cert_manager_release_managers
    # Allow release managers access to all required APIs for interacting with
    # the Cloud Build service.
    # https://cloud.google.com/iam/docs/understanding-roles#cloud-build-roles
    # We must explicitly grant the managed GCP service account IAM permission
    # to launch jobs in the project because this role is authoritatively managed.
    "roles/cloudbuild.builds.builder" = setunion(
      local.cert_manager_release_managers,
      [local.cert_manager_release_gcb_service_account],
    )
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
    "roles/owner"                               = local.cert_manager_release_managers
    "roles/resourcemanager.projectOwnerInvitee" = local.cert_manager_release_managers_invitee
    "roles/storage.admin"                       = local.cert_manager_release_managers
    "roles/logging.logWriter"                   = [module.prow-cluster-trusted.worker_pool_sa_member]
    "roles/monitoring.metricWriter"             = [module.prow-cluster-trusted.worker_pool_sa_member]
    (google_project_iam_custom_role.prow-gencred-custom-role["cert-manager-tests-trusted"].name) = [
      google_service_account.prow-gencred.member,
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
    "roles/owner"                               = local.cert_manager_release_managers
    "roles/resourcemanager.projectOwnerInvitee" = local.cert_manager_release_managers_invitee
    "roles/logging.logWriter"                   = [module.prow-cluster-untrusted.worker_pool_sa_member]
    "roles/monitoring.metricWriter"             = [module.prow-cluster-untrusted.worker_pool_sa_member]
    (google_project_iam_custom_role.prow-gencred-custom-role["cert-manager-tests-untrusted"].name) = [
      google_service_account.prow-gencred.member,
    ]
  }
}
