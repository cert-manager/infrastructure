locals {
  # List of users that have permission to stage and publish builds
  cert_manager_release_managers = toset([
    "user:tim.ramlot@jetstack.io",
    "user:tramlot@paloaltonetworks.com",
    "user:mael.valais@jetstack.io",
    "user:mvalais@paloaltonetworks.com",
    "user:richard.wall@jetstack.io",
    "user:riwall@paloaltonetworks.com",
    "user:ashley.davis@jetstack.io",
    "user:ashdavis@paloaltonetworks.com",
  ])

  gcp_region = "europe-west1"

  gke_zonal_location = "europe-west1-b"
  kms_location       = "europe-west1"
  bucket_location    = "EU"
  artifact_location  = "europe-west1"
}
