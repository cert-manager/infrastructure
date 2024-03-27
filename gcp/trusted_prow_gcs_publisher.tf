# service account that will be used to publish the logs to the GCS bucket
resource "google_service_account" "prow-gcs-publisher" {
  account_id   = "prow-gcs-publisher"
  display_name = "Service account that allows Prow to publish logs to the GCS bucket"
  project      = module.cert-manager-tests-trusted.project_id
}
