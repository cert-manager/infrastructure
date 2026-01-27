terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.17.0"
    }
  }
  required_version = ">= 1.6.1"
}

resource "google_storage_bucket" "bucket" {
  name = var.bucket_name

  location = var.location
  project  = var.project_id

  uniform_bucket_level_access = true
  public_access_prevention    = var.bucket_prevent_public_access ? "enforced" : "inherited"

  versioning {
    enabled = var.bucket_versioned
  }
}

resource "google_storage_bucket_iam_binding" "object-viewers" {
  bucket = google_storage_bucket.bucket.name

  role    = "roles/storage.objectViewer"
  members = var.bucket_viewers
}

resource "google_storage_bucket_iam_binding" "object-admins" {
  bucket = google_storage_bucket.bucket.name

  role    = "roles/storage.objectAdmin"
  members = var.bucket_admins
}
