locals {
  # List of users that have permission to stage and publish builds
  cert_manager_release_managers = toset([
    "user:tim.ramlot@jetstack.io",
    "user:mael.valais@jetstack.io",
    "user:richard.wall@jetstack.io",
    "user:ashley.davis@jetstack.io",
    "user:adam.talbot@jetstack.io",
  ])

  gcp_region = "europe-west1"

  gke_zonal_location = "europe-west1-b"
  kms_location       = "europe-west1"
  bucket_location    = "EU"
  artifact_location  = "europe-west1"
}
