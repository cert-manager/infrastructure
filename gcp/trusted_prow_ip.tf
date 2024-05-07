# IP used by the prow Kubernetes Ingress to expose the Prow UI.
# This Ingress is annotated with the "kubernetes.io/ingress.global-static-ip-name: prow-infra-cert-manager-io"
# annotation to use this static IP.
resource "google_compute_global_address" "prow_loadbalancer_ip" {
    project = module.cert-manager-tests-trusted.project_id
    name = "prow-infra-cert-manager-io"

    address_type = "EXTERNAL"
}
