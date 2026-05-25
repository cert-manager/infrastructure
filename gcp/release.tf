// Custom service account used by Cloud Build for cert-manager release jobs.
resource "google_service_account" "cert-manager-release-gcb" {
  project      = module.cert-manager-release.project_id
  account_id   = "cert-manager-release-gcb"
  display_name = "Cloud Build SA for cert-manager release jobs"
}

#####
## Define Cloud KMS keyring and related IAM permissions
#####

# Create a KMS keyring to hold the key used to encrypt release secrets.
resource "google_kms_key_ring" "cert-manager-release" {
  name     = "cert-manager-release"
  project  = module.cert-manager-release.project_id
  location = local.kms_location
}

# Create the actual key used to encrypt and decrypt secrets.
resource "google_kms_crypto_key" "cert-manager-release_secret-key" {
  name     = "cert-manager-release-secret-key"
  key_ring = google_kms_key_ring.cert-manager-release.id
  purpose  = "ENCRYPT_DECRYPT"

  # Prevent destroying this key to avoid us losing access to encrypted data.
  lifecycle {
    prevent_destroy = true
  }
}

# Define list of users with cryptoKeyEncrypter permissions on the release
# secret key.
resource "google_kms_crypto_key_iam_binding" "cert-manager-release_secret-key-encrypters" {
  crypto_key_id = google_kms_crypto_key.cert-manager-release_secret-key.id
  role          = "roles/cloudkms.cryptoKeyEncrypter"

  # Grant release managers permission to encrypt new secrets only.
  # This only needs to happen when creating new secrets or rotating existing
  # ones.
  members = local.cert_manager_release_managers
}

# Define list of users with cryptoKeyDecrypter permissions on the release
# secret key.
resource "google_kms_crypto_key_iam_binding" "cert-manager-release_secret-key-decrypters" {
  crypto_key_id = google_kms_crypto_key.cert-manager-release_secret-key.id
  role          = "roles/cloudkms.cryptoKeyDecrypter"

  # Grant the Cloud Build service account permission to decrypt secrets using
  # the secret key.
  members = [
    google_service_account.cert-manager-release-gcb.member,
  ]
}

# Key for signing cert-manager release artifacts
resource "google_kms_crypto_key" "cert-manager-release_signing-key" {
  name     = "cert-manager-release-signing-key"
  key_ring = google_kms_key_ring.cert-manager-release.id
  purpose  = "ASYMMETRIC_SIGN"

  # Prevent destroying this key; end-users of cert-manager will use the public part of this key
  # to verify signatures, meaning that while rotation is possible, it's a non-trivial task which will
  # ideally be communicated to the community well in advance. Destroying the key is a big decision
  # which shouldn't be taken lightly.
  lifecycle {
    prevent_destroy = true
  }

  version_template {
    # PKCS1 v1.5 and SHA512 are both requirements of helm for signing charts, meaning
    # that at the time of writing this is the only valid choice we have for the algorithm
    algorithm = "RSA_SIGN_PKCS1_4096_SHA512"
  }
}

# Define list of users who have permission to sign using this key.
resource "google_kms_crypto_key_iam_binding" "cert-manager-release_signing-key-signers" {
  crypto_key_id = google_kms_crypto_key.cert-manager-release_secret-key.id

  # https://cloud.google.com/kms/docs/reference/permissions-and-roles
  # "roles/cloudkms.signer" doesn't include permission to get the public key, which is required
  # when we sign helm charts and when we bootstrap the key. We don't call "verify" anywhere,
  # but signerVerifier is the closest role which includes both "signer" and "publicKeyViewer" and it's
  # not a security concern to allow signers to verify; it's not worth making a custom role.
  role = "roles/cloudkms.signerVerifier"

  # Signing should be done only by cmrel in cloudbuild jobs
  members = [
    google_service_account.cert-manager-release-gcb.member,
  ]
}
