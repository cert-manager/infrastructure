# This public artifact registry hosts all the docker images that we
# use for our prow testing clusters.

resource "google_artifact_registry_repository" "cert-manager-infra-images" {
  project  = module.cert-manager-tests-trusted.project_id
  location = local.artifact_location

  repository_id = "cert-manager-infra-images"
  description   = "Artifact registry that hosts the docker images for the cert-manager prow testing clusters."
  format        = "docker"
}

# Make the registry read-public
resource "google_artifact_registry_repository_iam_member" "cert-manager-infra-images-reader" {
  project  = module.cert-manager-tests-trusted.project_id
  location = local.artifact_location

  repository = google_artifact_registry_repository.cert-manager-infra-images.name
  role       = "roles/artifactregistry.reader"
  member     = "allUsers"
}

# service account that will be used to publish the docker images to the artifact registry
resource "google_service_account" "cert-manager-infra-images-publisher" {
  project = module.cert-manager-tests-trusted.project_id

  account_id   = "prow-infra-images-publisher"
  display_name = "Service account that allows Prow to publish docker images to the artifact registry"
}

resource "google_artifact_registry_repository_iam_member" "cert-manager-infra-images-writer" {
  project  = module.cert-manager-tests-trusted.project_id
  location = local.artifact_location

  repository = google_artifact_registry_repository.cert-manager-infra-images.name
  role       = "roles/artifactregistry.writer"
  member     = google_service_account.cert-manager-infra-images-publisher.member
}
