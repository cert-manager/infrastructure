// Bucket for storing database + encrypted root CA backup
resource "google_storage_bucket" "cert_manager_booth_bucket" {
  name          = "cert-manager-booth-bucket"
  location      = "EUROPE-WEST1"
  force_destroy = true

  public_access_prevention = "enforced"

  project = module.cert-manager-general.project_id
}

// Taken from https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances#terraform_1
resource "google_service_account" "print_your_cert_compute_sa" {
  project      = module.cert-manager-general.project_id

  account_id   = "pyc-compute-instance"
  display_name = "print-your-cert Service Account"
}

resource "google_compute_firewall" "print_your_cert_allow_tailscale" {
  project = module.cert-manager-general.project_id

  name          = "allow-tailscale"
  network       = "default"
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "udp"
    ports    = ["41641"]
  }

  target_tags = ["tailscale"]
}

resource "google_compute_instance" "print_your_cert" {
  project = module.cert-manager-general.project_id

  name         = "print-your-cert"
  machine_type = "e2-medium"
  zone         = format("%s-%s", local.gcp_region, "c")

  tags = ["http-server", "https-server", "tailscale"]

  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12-bookworm-v20240312"
    }
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
    email  = google_service_account.print_your_cert_compute_sa.email
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true
  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}

// Taken from https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances#terraform_1
resource "google_service_account" "booth_compute_sa" {
  project      = module.cert-manager-general.project_id

  account_id   = "guestbook-sa"
  display_name = "Booth Service Account"
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

  name         = "print-your-cert-guestbook"
  machine_type = "e2-medium"
  zone         = "us-central1-f"

  key_revocation_action_type = "NONE"

  tags = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12-bookworm-v20241009"
    }
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

  allow_stopping_for_update = true
  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}

##########################################################
# print-your-cert.cert-manager.io DNS records
##########################################################

resource "google_dns_record_set" "a-print-your-cert-cert-manager-io" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.print-your-cert-cert-manager-io.name

  name         = "print-your-cert.cert-manager.io."
  rrdatas      = [google_compute_instance.print_your_cert.network_interface.0.access_config.0.nat_ip]
  ttl          = 300
  type         = "A"
}

resource "google_dns_record_set" "a-guestbook-print-your-cert-cert-manager-io" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.print-your-cert-cert-manager-io.name

  name         = "guestbook.print-your-cert.cert-manager.io."
  rrdatas      = [google_compute_instance.guestbook.network_interface.0.access_config.0.nat_ip]
  ttl          = 300
  type         = "A"
}

resource "google_dns_record_set" "a-readonly-guestbook-print-your-cert-cert-manager-io" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.print-your-cert-cert-manager-io.name

  name         = "readonly-guestbook.print-your-cert.cert-manager.io."
  rrdatas      = [google_compute_instance.guestbook.network_interface.0.access_config.0.nat_ip]
  ttl          = 300
  type         = "A"
}
