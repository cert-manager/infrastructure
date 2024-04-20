#### Infrastructure for accessing other clusters from our "trusted management prow cluster" ####

# service account that will be used by the config uploader ProwJob via workload
# identity
resource "google_service_account" "prow-gencred" {
  project = module.cert-manager-tests-trusted.project_id

  account_id   = "prow-gencred"
  display_name = "Service account used to fetch the Kubernetes credentials from within the prow management cluster"
}

resource "google_service_account_iam_binding" "prow-gencred-workload-identity" {
  service_account_id = google_service_account.prow-gencred.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${module.prow-cluster-trusted.workload_pool}[default/gencred]"
  ]
}

resource "google_project_iam_custom_role" "prow-gencred-custom-role" {
  for_each = toset([
    module.cert-manager-tests-trusted.project_id,
    module.cert-manager-tests-untrusted.project_id,
  ])

  project = each.value

  role_id = "prow_gencred_custom_role"
  title   = "Custom Role for the gencred tool"
  # These permissions were obtained by running the gencred deployment and adding
  # each permission that was reported as missing in an error message.
  permissions = [
    "container.clusters.get",
    "container.clusterRoles.bind",
    "container.serviceAccounts.get",
    "container.serviceAccounts.create",
    "container.serviceAccounts.update",
    "container.serviceAccounts.createToken",
    "container.clusterRoleBindings.get",
    "container.clusterRoleBindings.create",
    "container.clusterRoleBindings.update",
    "container.configMaps.get",
  ]
}

resource "google_project_iam_binding" "prow-gencred-rolebinding" {
  for_each = google_project_iam_custom_role.prow-gencred-custom-role

  project = each.key

  role    = each.value.name
  members = [google_service_account.prow-gencred.member]
}
