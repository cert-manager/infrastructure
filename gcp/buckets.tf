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

  bucket_viewers = local.cert_manager_release_managers
  bucket_admins = [
    # Grant the GCB service account admin permissions on objects in the bucket.
    # This grants full control of objects, including listing, creating,
    # viewing, and deleting objects.
    # objectCreator is not sufficient, as the tool may need to delete or
    # overwrite existing files.
    # More information on roles can be found here:
    # https://cloud.google.com/iam/docs/understanding-roles#storage-roles
    local.cert_manager_release_gcb_service_account,
  ]
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
  bucket_admins = [
    google_service_account.prow-gcs-publisher.member
  ]
}

module "trusted-testgrid-bucket" {
  source = "./modules/gcp-bucket/"

  project_id  = module.cert-manager-tests-trusted.project_id
  location    = local.bucket_location
  bucket_name = "cert-manager-prow-testgrid"

  bucket_viewers = setunion(
    # Allow release managers to view TestGrid configs
    local.cert_manager_release_managers,
    [
      "serviceAccount:testgrid-canary@k8s-testgrid.iam.gserviceaccount.com",
      "serviceAccount:updater@k8s-testgrid.iam.gserviceaccount.com",
      # Temporary SA used for copy job, can be removed once we stop the job, which
      # can be stopped once https://github.com/kubernetes/test-infra/pull/32455 is merged
      "serviceAccount:project-771478705899@storage-transfer-service.iam.gserviceaccount.com",
    ],
  )
  bucket_admins = [
    google_service_account.testgrid-updater.member
  ]
}
