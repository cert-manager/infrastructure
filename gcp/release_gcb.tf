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

resource "google_cloudbuild_trigger" "cert-manager-package-debian" {
  description = "Builds the debian-based trust package for trust-manager. Run regularly via a scheduled trigger"

  location = "global"
  name     = "cert-manager-package-debian"
  project  = module.cert-manager-release.project_id

  approval_config {
    approval_required = false
  }
  git_file_source {
    path      = "gcb/ci-update-debian-trust-package.yaml"
    repo_type = "GITHUB"
    revision  = "refs/heads/main"
    uri       = "https://github.com/cert-manager/trust-manager"
  }
  source_to_build {
    ref       = "refs/heads/main"
    repo_type = "GITHUB"
    uri       = "https://github.com/cert-manager/trust-manager"
  }
}
