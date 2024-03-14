locals {
  # List of users that have permission to stage and publish builds
  cert_manager_release_managers = toset([
    "user:tim.ramlot@jetstack.io",
    "user:mael.valais@jetstack.io",
    "user:richard.wall@jetstack.io",
    "user:ashley.davis@jetstack.io",
  ])

  gcp_region = "europe-west1"
}
