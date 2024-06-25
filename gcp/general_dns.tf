
resource "google_dns_managed_zone" "cert-manager-io" {
  project = module.cert-manager-general.project_id

  name        = "cert-manager-io"
  dns_name    = "cert-manager.io."
  description = "cert-manager domain"
}

resource "google_dns_managed_zone" "print-your-cert-cert-manager-io" {
  project = module.cert-manager-general.project_id

  name        = "print-your-cert-cert-manager-io"
  dns_name    = "print-your-cert.cert-manager.io."
  description = "The domain used for https://github.com/cert-manager/print-your-cert"
}

resource "google_dns_record_set" "print-your-cert-cert-manager-io-delegation" {
  project      = module.cert-manager-general.project_id
  managed_zone = google_dns_managed_zone.cert-manager-io.name

  name    = "print-your-cert.cert-manager.io."
  type    = "NS"
  ttl     = "21600"
  rrdatas = google_dns_managed_zone.print-your-cert-cert-manager-io.name_servers
}

resource "google_dns_managed_zone" "cert-manager-dev" {
  project = module.cert-manager-general.project_id

  name        = "cert-manager-dev"
  dns_name    = "cert-manager.dev."
  description = "Extra cert-manager domain"
}

resource "google_dns_managed_zone" "trust-manager-io" {
  project = module.cert-manager-general.project_id

  name        = "trust-manager-io"
  dns_name    = "trust-manager.io."
  description = "trust-manager domain"
}

resource "google_dns_managed_zone" "trust-manager-dev" {
  project = module.cert-manager-general.project_id

  name        = "trust-manager-dev"
  dns_name    = "trust-manager.dev."
  description = "Extra trust-manager domain"
}
