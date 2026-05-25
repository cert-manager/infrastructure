terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.33.0"
    }
  }
  required_version = ">= 1.6.1"
}

locals {
  # see https://docs.cloud.google.com/iam/docs/service-agents
  # Since we authoritatively manage the project's IAM, we also need to include any roles required
  # by Google-managed service accounts for enabled APIs.
  service_agent_roles = {
    "artifactregistry.googleapis.com" = {
      "roles/artifactregistry.serviceAgent" = [
        "serviceAccount:service-${google_project.project.number}@gcp-sa-artifactregistry.iam.gserviceaccount.com",
      ]
    },
    "logging.googleapis.com" = {
      "roles/logging.serviceAgent" = [
        "serviceAccount:service-${google_project.project.number}@gcp-sa-logging.iam.gserviceaccount.com",
      ]
    },
    "bigquerydatatransfer.googleapis.com" = {
      "roles/bigquerydatatransfer.serviceAgent" = [
        "serviceAccount:service-${google_project.project.number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com",
      ]
    },
    "compute.googleapis.com" = {
      "roles/compute.serviceAgent" = [
        "serviceAccount:service-${google_project.project.number}@compute-system.iam.gserviceaccount.com",
      ]
    },
    "container.googleapis.com" = {
      "roles/container.serviceAgent" = [
        "serviceAccount:service-${google_project.project.number}@container-engine-robot.iam.gserviceaccount.com",
      ]
      "roles/container.defaultNodeServiceAgent" = [
        "serviceAccount:service-${google_project.project.number}@gcp-sa-gkenode.iam.gserviceaccount.com",
      ]
      "roles/gkehub.serviceAgent" = [
        "serviceAccount:service-${google_project.project.number}@gcp-sa-gkehub.iam.gserviceaccount.com",
      ]
    },
    "cloudbuild.googleapis.com" = {
      "roles/cloudbuild.serviceAgent" = [
        "serviceAccount:service-${google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com",
      ]
    },
    "cloudkms.googleapis.com" = {
      "roles/cloudkms.serviceAgent" = [
        "serviceAccount:service-${google_project.project.number}@gcp-sa-cloudkms.iam.gserviceaccount.com",
      ]
    },
    "pubsub.googleapis.com" = {
      "roles/pubsub.serviceAgent" = [
        "serviceAccount:service-${google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com",
      ]
    },
    "cloudscheduler.googleapis.com" = {
      "roles/cloudscheduler.serviceAgent" = [
        "serviceAccount:service-${google_project.project.number}@gcp-sa-cloudscheduler.iam.gserviceaccount.com",
      ]
    },
    "cloudfunctions.googleapis.com" = {
      "roles/cloudfunctions.serviceAgent" = [
        "serviceAccount:service-${google_project.project.number}@gcf-admin-robot.iam.gserviceaccount.com",
      ]
    },
    "cloudasset.googleapis.com" = {
      "roles/cloudasset.serviceAgent" = [
        "serviceAccount:service-${google_project.project.number}@gcp-sa-cloudasset.iam.gserviceaccount.com",
      ]
    },
    // TODO: Add more roles when we enable/ use more APIs.
    "iamcredentials.googleapis.com" = {},
    "storage.googleapis.com"        = {},
    "dns.googleapis.com"            = {},
  }

  # Default service accounts that GCP creates automatically for all projects
  # We need to include them since we're using an authoritative IAM policy
  default_service_accounts = {
    "roles/editor" = [
      "serviceAccount:${google_project.project.number}@cloudservices.gserviceaccount.com",
    ]
  }
}

resource "google_project" "project" {
  name            = var.project_name
  project_id      = var.project_id
  folder_id       = var.project_folder_id
  billing_account = var.project_billing_id

  auto_create_network = false

  lifecycle {
    prevent_destroy = true
  }
}

# Lien to prevent manual deletion https://cloud.google.com/resource-manager/docs/project-liens
resource "google_resource_manager_lien" "block_deletion" {
  parent       = "projects/${google_project.project.number}"
  restrictions = ["resourcemanager.projects.delete"]
  origin       = "${var.project_id}-project-lien"
  reason       = "This project is an important environment"

  lifecycle {
    prevent_destroy = true
  }
}

# Enable all required APIs for the project.
resource "google_project_service" "project_apis" {
  for_each = var.project_apis
  project  = google_project.project.project_id
  service  = each.value

  # Generate an error if any enabled services depend on this service when destroying it.
  disable_dependent_services = false

  # Don't actually disable the service when the resource is destroyed.
  # This prevents accidental service disruption when removing from Terraform.
  disable_on_destroy = false
}

# Merge all IAM bindings, combining members for duplicate roles
locals {
  # Collect all role bindings from different sources
  all_role_bindings = concat(
    [for api in var.project_apis : local.service_agent_roles[api]],
    [var.project_iam],
    [local.default_service_accounts]
  )

  # Merge bindings, combining member lists for the same role
  merged_iam = {
    for role in distinct(flatten([for binding_map in local.all_role_bindings : keys(binding_map)])) :
    role => distinct(flatten([
      for binding_map in local.all_role_bindings :
      lookup(binding_map, role, [])
    ]))
  }
}

# Authoritative IAM policy for the project
data "google_iam_policy" "project" {
  dynamic "binding" {
    for_each = local.merged_iam
    content {
      role    = binding.key
      members = binding.value
    }
  }

  dynamic "audit_config" {
    for_each = var.audit_configs
    content {
      service = audit_config.value.service
      dynamic "audit_log_configs" {
        for_each = audit_config.value.log_types
        content {
          log_type = audit_log_configs.value
        }
      }
    }
  }
}

resource "google_project_iam_policy" "project" {
  project     = google_project.project.project_id
  policy_data = data.google_iam_policy.project.policy_data
}
