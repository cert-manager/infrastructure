#### Infrastructure for creating, uploading and accessing cert-manager TestGrid configs ####
#
# TestGrid (https://github.com/GoogleCloudPlatform/testgrid) is a UI
# for Prow. We and some other kubernetes-related projects use a hosted TestGrid
# instance at https://testgrid.k8s.io/. We have a ProwJob that generates
# TestGrid configuration on ProwJob config changes and pushes it to the
# cert-manager-testgrid GCS bucket. TestGrid reads it from this bucket via [Config
# Merger](https://github.com/GoogleCloudPlatform/testgrid/tree/master/cmd/config_merge)
#
# See https://github.com/kubernetes/test-infra/blob/master/testgrid/merging.md

# service account that will be used by the config uploader ProwJob via workload
# identity
resource "google_service_account" "testgrid-updater" {
  account_id   = "testgrid-updater"
  display_name = "Service account that allows config uploader ProwJob access to the GCS bucket with TestGrid configs"
  project      = module.cert-manager-tests-trusted.project_id
}

# This IAM binding allows testgrid-updater Kubernetes service account in
# test-pods namespace to impersonate testgrid-updater Google Service Account.
# Note that the member value includes Kubernetes namespace and service account
# name
# https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
resource "google_service_account_iam_binding" "testgrid-updater-workload-identity" {
  service_account_id = google_service_account.testgrid-updater.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${module.prow-cluster-trusted.workload_pool}[test-pods/testgrid-updater]"
  ]
}
