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

resource "google_artifact_registry_repository_iam_member" "cert-manager-infra-images-writer" {
  project  = module.cert-manager-tests-trusted.project_id
  location = local.artifact_location

  repository = google_artifact_registry_repository.cert-manager-infra-images.name
  role       = "roles/artifactregistry.writer"
  member     = google_service_account.image-builder.member
}
