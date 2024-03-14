resource "google_storage_bucket" "default" {
  name                        = "cert-manager-terraform-state"
  location                    = "EU"
  project                     = module.cert-manager-general.project_id
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}
