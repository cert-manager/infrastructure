# GSAs impersonated via Workload Identity by KSAs in the test-pods namespace of
# the trusted and untrusted clusters
# (cert-manager/testing prow/test-pods/{trusted,untrusted}_cluster/02_prowjob_sa.yaml).
#
# - prowjob-default: default service account for ProwJobs in each cluster, set
#   as default_service_account_name in the Prow decoration config so that
#   pod-utils can upload artifacts to GCS without a static service account key.
# - testgrid-updater: used by the config uploader ProwJob to push TestGrid
#   configs to the cert-manager-prow-testgrid GCS bucket. TestGrid then reads
#   it via Config Merger
#   (https://github.com/GoogleCloudPlatform/testgrid/tree/master/cmd/config_merge).
#   See https://github.com/kubernetes/test-infra/blob/master/testgrid/merging.md
# - image-builder: used by image-building postsubmit ProwJobs to push container
#   images to the cert-manager-infra-images Artifact Registry without a static
#   service account key.

resource "google_service_account" "prowjob-default-trusted" {
  account_id   = "prowjob-default"
  display_name = "Default service account for ProwJobs in the trusted cluster"
  project      = module.cert-manager-tests-trusted.project_id
}

resource "google_service_account_iam_binding" "prowjob-default-trusted-workload-identity" {
  service_account_id = google_service_account.prowjob-default-trusted.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${module.prow-cluster-trusted.workload_pool}[test-pods/prowjob-default]"
  ]
}

resource "google_service_account" "prowjob-default-untrusted" {
  account_id   = "prowjob-default"
  display_name = "Default service account for ProwJobs in the untrusted cluster"
  project      = module.cert-manager-tests-untrusted.project_id
}

resource "google_service_account_iam_binding" "prowjob-default-untrusted-workload-identity" {
  service_account_id = google_service_account.prowjob-default-untrusted.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${module.prow-cluster-untrusted.workload_pool}[test-pods/prowjob-default]"
  ]
}

resource "google_service_account" "testgrid-updater" {
  account_id   = "testgrid-updater"
  display_name = "Service account that allows config uploader ProwJob access to the GCS bucket with TestGrid configs"
  project      = module.cert-manager-tests-trusted.project_id
}

resource "google_service_account_iam_binding" "testgrid-updater-workload-identity" {
  service_account_id = google_service_account.testgrid-updater.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${module.prow-cluster-trusted.workload_pool}[test-pods/testgrid-updater]"
  ]
}

resource "google_service_account" "image-builder" {
  account_id   = "image-builder"
  display_name = "Service account for image-building ProwJobs that push to Artifact Registry"
  project      = module.cert-manager-tests-trusted.project_id
}

resource "google_service_account_iam_binding" "image-builder-workload-identity" {
  service_account_id = google_service_account.image-builder.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${module.prow-cluster-trusted.workload_pool}[test-pods/image-builder]"
  ]
}
