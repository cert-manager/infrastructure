// Storage buckets

resource "google_storage_bucket" "cert_manager_release_cloudbuild" {
  name     = "cert-manager-release_cloudbuild"
  location = "US"
  project  = module.cert-manager-release.project_id
}

resource "google_storage_bucket" "cert_manager_release_backup_2022_03_30" {
  name                        = "cert-manager-release-backup-2022-03-30"
  location                    = "EU"
  project                     = module.cert-manager-release.project_id
  uniform_bucket_level_access = true
}

// Firewall rules

resource "google_compute_firewall" "default_allow_icmp" {
  allow {
    protocol = "icmp"
  }

  description   = "Allow ICMP from anywhere"
  direction     = "INGRESS"
  name          = "default-allow-icmp"
  network       = "https://www.googleapis.com/compute/v1/projects/cert-manager-release/global/networks/default"
  priority      = 65534
  project       = module.cert-manager-release.project_id
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "default_allow_internal" {
  allow {
    ports    = ["0-65535"]
    protocol = "tcp"
  }

  allow {
    ports    = ["0-65535"]
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  description   = "Allow internal traffic on the default network"
  direction     = "INGRESS"
  name          = "default-allow-internal"
  network       = "https://www.googleapis.com/compute/v1/projects/cert-manager-release/global/networks/default"
  priority      = 65534
  project       = module.cert-manager-release.project_id
  source_ranges = ["10.128.0.0/9"]
}

// Service accounts

resource "google_service_account" "dns01_solver" {
  account_id   = "dns01-solver"
  display_name = "dns01-solver"
  project      = module.cert-manager-release.project_id
}

resource "google_service_account" "give_me_my_cluster" {
  account_id   = "give-me-my-cluster"
  display_name = "For the give-me-my-cluster CLI"
  project      = module.cert-manager-release.project_id
}

// IAM roles

resource "google_project_iam_custom_role" "cloudkmskeyversiongetter" {
  description = "Created on: 2021-10-13"
  permissions = ["cloudkms.cryptoKeyVersions.get", "cloudkms.cryptoKeys.get"]
  project     = module.cert-manager-release.project_id
  role_id     = "CloudKMSKeyVersionGetter"
  stage       = "GA"
  title       = "Cloud KMS Key Version Getter"
}
