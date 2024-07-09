
##########################################################
# cert-manager.io and cert-manager.dev DNS records
##########################################################

resource "google_dns_record_set" "txt-github-challenge" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.cert-manager-io.name
  
  name         = "_github-challenge-cert-manager-org.cert-manager.io."
  rrdatas      = ["\"e96129d5fd\""]
  ttl          = 300
  type         = "TXT"
}

resource "google_dns_record_set" "txt-scarf-challenge" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.cert-manager-io.name

  name         = "_scarf-sh-challenge-cert-manager.oci.cert-manager.io."
  rrdatas      = ["\"N4SDRJUAN5QQUU2AAY2Q\""]
  ttl          = 300
  type         = "TXT"
}

resource "google_dns_record_set" "txt-netlify-challenge" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.cert-manager-io.name

  name         = "verified-for-netlify.cert-manager.io."
  rrdatas      = ["\"verifying\" \"for\" \"netlify\" \"support\" \"case\" \"#71692\""]
  ttl          = 300
  type         = "TXT"
}

resource "google_dns_record_set" "a-prow-infra-cert-manager-io" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.cert-manager-io.name

  name         = "prow.infra.cert-manager.io."
  rrdatas      = [google_compute_global_address.prow_loadbalancer_ip.address]
  ttl          = 300
  type         = "A"
}

resource "google_dns_record_set" "cname-oci-cert-manager-io" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.cert-manager-io.name

  name         = "oci.cert-manager.io."
  rrdatas      = ["cert-manager.docker.scarf.sh."]
  ttl          = 300
  type         = "CNAME"
}

resource "google_dns_record_set" "mx-cert-manager-io" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.cert-manager-io.name
  
  name         = "cert-manager.io."
  rrdatas = [
    "1 aspmx.l.google.com.",
    "5 alt1.aspmx.l.google.com.",
    "5 alt2.aspmx.l.google.com.",
    "10 alt3.aspmx.l.google.com.",
    "10 alt4.aspmx.l.google.com.",
  ]
  ttl  = 300
  type = "MX"
}

## Netlify DNS records

resource "google_dns_record_set" "a-cert-manager-io" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.cert-manager-io.name

  name         = "cert-manager.io."
  rrdatas      = ["75.2.60.5"]
  ttl          = 300
  type         = "A"
}

resource "google_dns_record_set" "alias-cert-manager-dev" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.cert-manager-dev.name

  name         = "cert-manager.dev."
  rrdatas      = ["apex-loadbalancer.netlify.com."]
  ttl          = 300
  type         = "ALIAS"
}

resource "google_dns_record_set" "cname-docs-cert-manager-io" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.cert-manager-io.name

  name         = "docs.cert-manager.io."
  rrdatas      = ["cert-manager.netlify.app."]
  ttl          = 300
  type         = "CNAME"
}

resource "google_dns_record_set" "cname-netlify-cert-manager-io" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.cert-manager-io.name

  name         = "netlify.cert-manager.io."
  rrdatas      = ["cert-manager.netlify.com."]
  ttl          = 300
  type         = "CNAME"
}

resource "google_dns_record_set" "cname-www-cert-manager-io" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.cert-manager-io.name
  
  name         = "www.cert-manager.io."
  rrdatas      = ["cert-manager.io."]
  ttl          = 300
  type         = "CNAME"
}
