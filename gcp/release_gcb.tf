resource "google_cloudbuild_trigger" "cert-manager-build-on-tag" {
  description = "Builds cert-manager when a tag is pushed"

  filename = "gcb/build_cert_manager.yaml"
  location = "global"
  name     = "cert-manager-build-on-tag"
  project  = module.cert-manager-release.project_id

  approval_config {
    approval_required = false
  }
  github {
    name  = "cert-manager"
    owner = "cert-manager"
    push {
      tag = "^v.*$"
    }
  }
}
