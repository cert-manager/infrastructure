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

// IAM roles

resource "google_project_iam_custom_role" "cloudkmskeyversiongetter" {
  description = "Created on: 2021-10-13"
  permissions = ["cloudkms.cryptoKeyVersions.get", "cloudkms.cryptoKeys.get"]
  project     = module.cert-manager-release.project_id
  role_id     = "CloudKMSKeyVersionGetter"
  stage       = "GA"
  title       = "Cloud KMS Key Version Getter"
}
