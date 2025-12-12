terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.50.0"
    }
  }
  required_version = ">= 1.6.1"
}

resource "google_project" "project" {
  name            = var.project_name
  project_id      = var.project_id
  folder_id       = var.project_folder_id
  billing_account = var.project_billing_id

  auto_create_network = false

  lifecycle {
    prevent_destroy = "true"
  }
}

# Lien to prevent manual deletion https://cloud.google.com/resource-manager/docs/project-liens 
resource "google_resource_manager_lien" "block_deletion" {
  parent       = "projects/${google_project.project.number}"
  restrictions = ["resourcemanager.projects.delete"]
  origin       = "${var.project_id}-project-lien"
  reason       = "This project is an important environment"
}

# Add all cert-manager release managers as 'owners' of the GCP project.
resource "google_project_iam_member" "project_owners" {
  for_each = var.project_owners
  project  = google_project.project.project_id
  role     = "roles/owner"
  member   = each.value
}

# Enable all required APIs for the project.
resource "google_project_service" "project_apis" {
  for_each = var.project_apis
  project  = google_project.project.project_id
  service  = each.value

  # If this service is disabled (i.e. the Terraform resource is destroyed),
  # automatically disable any dependent project services.
  disable_dependent_services = true
}
