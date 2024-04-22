// Taken from https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances#terraform_1
resource "google_service_account" "booth_compute_sa" {
  account_id   = "booth-compute-instance"
  display_name = "Booth Service Account"
  project      = module.cert-manager-general.project_id
}

// Bucket for storing database + encrypted root CA backup
resource "google_storage_bucket" "cert_manager_booth_bucket" {
  name          = "cert-manager-booth-bucket"
  location      = "EUROPE-WEST1"
  force_destroy = true

  public_access_prevention = "enforced"

  project = module.cert-manager-general.project_id
}

resource "google_storage_bucket_iam_member" "bucket_access_policy" {
  bucket     = google_storage_bucket.cert_manager_booth_bucket.name
  role       = "roles/storage.admin"
  member     = format("serviceAccount:%s", google_service_account.booth_compute_sa.email)
  depends_on = [google_storage_bucket.cert_manager_booth_bucket]
}

// Taken from https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances#terraform_1
resource "google_compute_instance" "guestbook" {
  project = module.cert-manager-general.project_id

  name         = "guestbook"
  machine_type = "n1-standard-1"
  zone         = format("%s-%s", local.gcp_region, "c")

  tags = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    # Google recommends custom service accounts with `cloud-platform` scope with
    # specific permissions granted via IAM Roles.
    # This approach lets you avoid embedding secret keys or user credentials
    # in your instance, image, or app code
    email  = google_service_account.booth_compute_sa.email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}
