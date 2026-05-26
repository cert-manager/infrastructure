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
  bucket_admins = setunion(
    local.cert_manager_release_managers,
    [
      # Grant the GCB service account admin permissions on objects in the bucket.
      # This grants full control of objects, including listing, creating,
      # viewing, and deleting objects.
      # objectCreator is not sufficient, as the tool may need to delete or
      # overwrite existing files.
      # More information on roles can be found here:
      # https://cloud.google.com/iam/docs/understanding-roles#storage-roles
      google_service_account.cert-manager-release-gcb.member,
    ],
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
  bucket_admins = setunion(
    local.cert_manager_release_managers,
    [
      # The crier application needs access to the bucket
      google_service_account.prow-control-plane["crier"].member,
      # Let prow jobs push their logs to the bucket (both default prow job service accounts and the testgrid updater service account)
      google_service_account.prowjob-default-trusted.member,
      google_service_account.prowjob-default-untrusted.member,
      google_service_account.testgrid-updater.member,
    ],
  )
}

module "trusted-testgrid-bucket" {
  source = "./modules/gcp-bucket/"

  project_id  = module.cert-manager-tests-trusted.project_id
  location    = local.bucket_location
  bucket_name = "cert-manager-prow-testgrid"

  bucket_viewers = [
    "serviceAccount:testgrid-canary@k8s-testgrid.iam.gserviceaccount.com",
    "serviceAccount:updater@k8s-testgrid.iam.gserviceaccount.com",
  ]
  bucket_admins = setunion(
    local.cert_manager_release_managers,
    [google_service_account.testgrid-updater.member],
  )
}
