terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.36.0"
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

  lifecycle {
    prevent_destroy = true
  }
}

data "google_iam_policy" "bucket" {
  dynamic "binding" {
    for_each = length(var.bucket_viewers) > 0 ? [1] : []
    content {
      role    = "roles/storage.objectViewer"
      members = var.bucket_viewers
    }
  }

  dynamic "binding" {
    for_each = length(var.bucket_writers) > 0 ? [1] : []
    content {
      role    = "roles/storage.objectUser"
      members = var.bucket_writers
    }
  }

  dynamic "binding" {
    for_each = length(var.bucket_admins) > 0 ? [1] : []
    content {
      role    = "roles/storage.objectAdmin"
      members = var.bucket_admins
    }
  }

  dynamic "binding" {
    for_each = length(var.admins) > 0 ? [1] : []
    content {
      role    = "roles/storage.admin"
      members = var.admins
    }
  }
}

resource "google_storage_bucket_iam_policy" "bucket" {
  bucket      = google_storage_bucket.bucket.name
  policy_data = data.google_iam_policy.bucket.policy_data
}
