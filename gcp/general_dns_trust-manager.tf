
##########################################################
# trust-manager.io and trust-manager.dev DNS records
##########################################################

## Netlify DNS records

resource "google_dns_record_set" "alias-trust-manager-io" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.trust-manager-io.name

  name         = "trust-manager.io."
  rrdatas      = ["apex-loadbalancer.netlify.com."]
  ttl          = 300
  type         = "ALIAS"
}

resource "google_dns_record_set" "alias-trust-manager-dev" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.trust-manager-dev.name

  name         = "trust-manager.dev."
  rrdatas      = ["apex-loadbalancer.netlify.com."]
  ttl          = 300
  type         = "ALIAS"
}
