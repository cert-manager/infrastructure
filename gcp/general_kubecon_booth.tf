// Bucket for storing database + encrypted root CA backup
resource "google_storage_bucket" "cert_manager_booth_bucket" {
  name          = "cert-manager-booth-bucket"
  location      = "EUROPE-WEST1"
  force_destroy = true

  public_access_prevention = "enforced"

  project = module.cert-manager-general.project_id
}
