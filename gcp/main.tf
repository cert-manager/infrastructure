terraform {
  backend "gcs" {
    bucket = "cert-manager-terraform-state"
    prefix = "terraform/state"
  }

  # backend "local" {
  #  path = "terraform.tfstate"
  # }

  required_version = ">= 1.6.1"
}

provider "google" {
  region = local.gcp_region

  default_labels = {
    managed-by = "terraform"
  }
}
