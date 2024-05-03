# IP used byt the prow Kubernetes service (of type LoadBalancer) to expose the Prow UI.
# This service is annotated with the kubernetes.io/ingress.global-static-ip-name: prow-infra-cert-manager-io
# annotation to use this IP.
resource "google_compute_address" "prow_loadbalancer_ip" {
    project = module.cert-manager-tests-trusted.project_id
    region = local.gcp_region
    name = "prow-infra-cert-manager-io"

    address_type = "EXTERNAL"
    network_tier = "PREMIUM"
}
