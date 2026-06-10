terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.36.0"
    }
  }
  required_version = ">= 1.6.1"
}

resource "google_folder" "folder" {
  display_name = var.folder_display_name
  parent       = var.folder_parent

  lifecycle {
    prevent_destroy = true
  }
}

check "folder_id_match" {
  assert {
    condition     = google_folder.folder.folder_id == var.folder_id
    error_message = "Folder ID mismatch: expected ${var.folder_id}, got ${google_folder.folder.folder_id}"
  }
}

# Authoritative IAM policy for the folder
data "google_iam_policy" "folder" {
  dynamic "binding" {
    for_each = var.folder_iam
    content {
      role    = binding.key
      members = binding.value
    }
  }
}

resource "google_folder_iam_policy" "folder" {
  folder      = google_folder.folder.name
  policy_data = data.google_iam_policy.folder.policy_data
}
