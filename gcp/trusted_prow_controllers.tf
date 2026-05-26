# Per-component GSAs for Prow control-plane workloads. Each KSA in
# cert-manager/testing prow/cluster/<component>_rbac.yaml is bound to its GSA
# via Workload Identity; the static kubeconfigs use gke-gcloud-auth-plugin to
# authenticate. Replaces the gencred-rotated Secrets, mirroring upstream
# https://github.com/kubernetes/test-infra/pull/35449.

locals {
  # KSA name (in the trusted cluster's default namespace) -> GSA account_id.
  prow_control_plane_components = {
    "deck"                    = "prow-deck"
    "sinker"                  = "prow-sinker"
    "prow-controller-manager" = "prow-controller-manager"
    "crier"                   = "prow-crier"
    "hook"                    = "prow-hook"
  }
}

resource "google_service_account" "prow-control-plane" {
  for_each = local.prow_control_plane_components

  project = module.cert-manager-tests-trusted.project_id

  account_id   = each.value
  display_name = "Prow ${each.key} controller"
  description  = "Accesses prow-trusted and prow-untrusted GKE clusters via Workload Identity"
}

resource "google_service_account_iam_binding" "prow-control-plane-workload-identity" {
  for_each = local.prow_control_plane_components

  service_account_id = google_service_account.prow-control-plane[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${module.prow-cluster-trusted.workload_pool}[default/${each.key}]"
  ]
}
