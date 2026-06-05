module "general-tfstate-bucket" {
  source = "./modules/gcp-bucket/"

  project_id  = module.cert-manager-general.project_id
  location    = local.bucket_location
  bucket_name = "cert-manager-terraform-state"

  bucket_versioned = true
}

module "release-bucket" {
  source = "./modules/gcp-bucket/"

  project_id  = module.cert-manager-release.project_id
  location    = local.bucket_location
  bucket_name = "cert-manager-release"

  bucket_viewers = []
  bucket_writers = [
    # Grant the GCB service account write permissions on objects in the bucket.
    # This grants full control of objects, including listing, creating,
    # viewing, and deleting objects.
    # objectCreator is not sufficient, as the tool may need to delete or
    # overwrite existing files.
    # More information on roles can be found here:
    # https://cloud.google.com/iam/docs/understanding-roles#storage-roles
    google_service_account.cert-manager-release-gcb.member,
  ]
  bucket_admins = local.cert_manager_release_managers
}

module "release-logs-bucket" {
  source = "./modules/gcp-bucket/"

  project_id  = module.cert-manager-release.project_id
  location    = local.bucket_location
  bucket_name = "cert-manager-release-logs"
  bucket_admins = setunion(
    local.cert_manager_release_managers,
    [google_service_account.cert-manager-release-gcb.member],
  )
}

module "trusted-artifacts-bucket" {
  source = "./modules/gcp-bucket/"

  project_id  = module.cert-manager-tests-trusted.project_id
  location    = local.bucket_location
  bucket_name = "cert-manager-prow-artifacts"

  bucket_prevent_public_access = false
  bucket_viewers = [
    "allUsers"
  ]
  bucket_writers = [
    # The crier application needs access to the bucket
    google_service_account.prow-control-plane["crier"].member,
    # Let prow jobs push their logs to the bucket
    # By default prow jobs use the prowjob-default service account, but some
    # jobs use a custom service account, so we need to grant access to both.
    google_service_account.prowjob-default-trusted.member,
    google_service_account.prowjob-default-untrusted.member,
    google_service_account.testgrid-updater.member,
    google_service_account.image-builder.member,
  ]
  bucket_admins = local.cert_manager_release_managers
}

module "trusted-testgrid-bucket" {
  source = "./modules/gcp-bucket/"

  project_id  = module.cert-manager-tests-trusted.project_id
  location    = local.bucket_location
  bucket_name = "cert-manager-prow-testgrid"

  bucket_viewers = [
    "serviceAccount:testgrid-canary@k8s-testgrid.iam.gserviceaccount.com",
    "serviceAccount:updater@k8s-testgrid.iam.gserviceaccount.com",
    # The deck application needs access to the bucket
    google_service_account.prow-control-plane["deck"].member,
  ]
  bucket_writers = [
    google_service_account.testgrid-updater.member,
  ]
  bucket_admins = local.cert_manager_release_managers
}
