<p align="center">
  <img src="https://raw.githubusercontent.com/cert-manager/cert-manager/d53c0b9270f8cd90d908460d69502694e1838f5f/logo/logo-small.png" height="256" width="256" alt="cert-manager project logo" />
</p>

# cert-manager Infrastructure

All infrastructure required by the cert-manager project. This includes:

- infrastructure-as-code (Terraform)
- details of services used by the project

## Services We Use

As a project, cert-manager relies on several external services for different tasks. Some require
access controls, which should ideally be open to any recognised cert-manager maintainer.

Here, we list any services we know about and the method by which we change / configure / interact with those services.

### Google Groups: cert-manager-maintainers

[`cert-manager-maintainers`](https://groups.google.com/g/cert-manager-maintainers) is the ultimate decider of who's a recognised maintainer.
All other memberships should be based off this group, and if a maintainer retires from the project, they should be removed from this group.

There should be automation added to ensure that members of this group are:

- able to access any secrets they need (e.g. login credentials)
- listed in the CNCF Maintainers list (see details below)
- admins of the cert-manager GitHub org.
- owners of other cert-manager Google Groups

This group is managed by existing group owners.

### Google Groups: cert-manager-security

[`cert-manager-security`](https://groups.google.com/g/cert-manager-security) is the single point of contact for people wanting to report
security vulnerabilities, as documented in the [Vulnerability Reporting Process](https://github.com/jetstack/cert-manager/blob/master/SECURITY.md).

Members of this group should also be maintainers, and thus this group should be a subset of `cert-manager-maintainers`.

Managed by existing group owners.

### Google Groups: cert-manager-dev

[`cert-manager-dev`](https://groups.google.com/g/cert-manager-dev) is the open-to-the-public group encompassing anyone who's interested
in cert-manager development. It's a place for people to ask questions and get updates about the project, outside of Slack.

Owners should be those in the `cert-manager-maintainers` group, but anyone is free to join the group.

### Mailing Lists: cncf-cert-manager-maintainers

There's a [CNCF-hosted mailing list](https://lists.cncf.io/g/cncf-cert-manager-maintainers/directory) for cert-manager maintainers
which uses groups.io

It contains a mixture of CNCF people and cert-manager people. In the future it might be good to sync this mailing list with
the cert-manager-maintainers Google group.

## 1Password

Maintainers get access to the cert-manager team on 1Password and are equally given the "Owner" role.
1Password offers a free team plan for open-source projects. The team URL is https://cert-manager.1password.com.

### Quay

Currently, cert-manager container images are hosted on quay.io under the Jetstack organization which is controlled by Venafi. Admin
credentials are available on the cert-manager 1Password team.

It's a goal of the cert-manager project to migrate images to be hosted under a `cert-manager` organization, but this introduces
non-trivial operational challenges which we'd have to face to perform a migration.

cert-manager container images are pushed to Quay via a robot account which is configured in Google Cloud Build.

Other projects (e.g. trust-manager, csi-driver, etc) use GitHub actions to automatically build their OCI images and push them to quay.io (using scoped quay.io robot credentials available as GH action secrets).

### Zoom

We are using Zoom for the dev biweekly meetings. The CNCF pays for a Zoom pro account. The email is `cncf-certmanager-project@cncf.io`,
and the password is in the cert-manager 1Password team.

### CNCF Calendar

The dev biweekly meetings show on the [CNCF calendar]([https://www.cncf.io/calendar/](https://tockify.com/cncf.public.events/monthly?search=cert-manager)). This calendar is manually managed by the CNCF through the CNCF service desk. Changes to the invitations sent to `cert-manager-dev@googlegroups.com` need to be manually propagated by opening a ticket on the CNCF service desk.

### Slack

We have 2 Slack channels on Kubernetes slack:

- [`cert-manager`](https://kubernetes.slack.com/archives/C4NV3DWUC) for user questions, chat and support
- [`cert-manager-dev`](https://kubernetes.slack.com/archives/CDEQJ0Q8M) for discussion on cert-manager development.

Administration of both is done by Kubernetes slack admins.

Maintainers should also have access to the [CNCF slack](https://cloud-native.slack.com/archives/C08PSKWQL), although this isn't used much.

We also have the Slack user group `@cert-manager-maintainers` defined in [kubernetes/community#7360](https://github.com/kubernetes/community/issues/7360).
The list of Slack usernames in this file was extracted from the GitHub usernames and there
might need some adjustments since the Slack usernames are private to each Slack user.

### Netlify

The main site `cert-manager.io` is served through Netlify and lives in the CNCF-owned "CNCF Projects 2" Netlify organisation. An account with Developer permissions for this website is stored in the cert-manager 1Password team.

### ArtifactHub

We distribute our built helm charts [on ArtifactHub](https://artifacthub.io/packages/helm/cert-manager/cert-manager).

Login details are stored in the cert-manager 1Password team.

### Algolia

Provides an API for searching the cert-manager website. We're in [DocSearch](https://docsearch.algolia.com/docs/what-is-docsearch/)
which is Algolia's free tool provided open-source projects.

The cert-manager maintainers have access to configure Algolia through a login stored in the cert-manager 1Password team.

Crawlers can be configured here: [https://crawler.algolia.com/admin/crawlers](https://crawler.algolia.com/admin/crawlers)

The Algolia app (Team, API Keys) can be configured here: [https://www.algolia.com/apps/01YP6XYAE7/dashboard](https://www.algolia.com/apps/01YP6XYAE7/dashboard)

The Algolia API Key must be configured as an environment variable in Netlify.

The other Algolia settings can be configured here: [https://github.com/cert-manager/website/blob/master/netlify.toml](https://github.com/cert-manager/website/blob/master/netlify.toml)

### Google Cloud Platform

Hosts test infrastructure, release infrastructure, past releases, and DNS for our domains.

- The infrastructure is managed by Terraform/ Tofu, in the `./gcp` directory of this repository (see [README](./gcp/README.md) for more details).
- Some resources are still running in the Jetstack org, but we are actively moving them to the terraform in this repository.

### GitHub Org

The [cert-manager GitHub org](https://github.com/cert-manager/) holds all project repos. Configuration is done by admins, and the list of admins should
match the membership of the cert-manager-maintainers Google group.

We also have a bot - `cert-manager-bot` - with high levels of access to the cert-manager org. It is used by prow (eg. [the mounted bot PAT](https://github.com/cert-manager/testing/blob/091d46e46d154f8d77401b108b61383080a80777/prow/cluster/cherrypicker_deployment.yaml#L74-L76)) in combination with the cert-manager-prow GitHub app (eg. [the mounted GH app token](https://github.com/cert-manager/testing/blob/091d46e46d154f8d77401b108b61383080a80777/prow/cluster/tide_deployment.yaml#L58-L60)).

### CNCF Maintainers

At the very least, all recognised cert-manager maintainers should be listed in the CNCF [`project-maintainers.csv`](https://github.com/cncf/foundation/blob/main/project-maintainers.csv).

This can be added to by existing maintainers, such as in [this PR](https://github.com/cncf/foundation/pull/213).

There are also CNCF mailing lists, although we don't currently have an exhaustive list of which ones are relevant.

### Social Media

Credentials for all social media accounts are stored in the cert-manager 1Password team.

#### Twitter / X

[`@CertManager`](https://twitter.com/CertManager/) is used by maintainers to tweet about
important releases or community updates. The password for the account is available in the
cert-manager 1Password team.

#### Mastodon / infosec.exchange

[`@CertManager@infosec.exchange`](https://infosec.exchange/@CertManager) is used by maintainers
to toot about important releases or community updates. The password for the account is available
in the cert-manager 1Password team.

### cert-manager YouTube Account

All cert-manager maintainers should be able to access the cert-manager [brand YouTube account](https://www.youtube.com/channel/UCNPMkzGrAsQxVUFMPn7n88Q)
if desired. Access is managed by existing maintainers who can administer that account by visiting the
[Brand Accounts](https://myaccount.google.com/brandaccounts) page.

Note that to upload videos or do other actions, you need to click on your profile in the top right of YouTube
and "switch account" to the cert-manager brand account.

Currently, videos from biweekly meetings are being manually uploaded to YouTube by maintainers.

### TestGrid

Testgrid is hosted [here](https://testgrid.k8s.io/cert-manager) with dashboards for all supported releases.

The testgrid config lives in the [testing repo](https://github.com/cert-manager/testing/blob/091d46e46d154f8d77401b108b61383080a80777/config/testgrid/dashboards.yaml).

Testgrid loads the data from a GCS bucket `gs://cert-manager-prow-testgrid/`. A reference to this bucket is configured here: [canary.yaml](https://github.com/kubernetes/test-infra/blob/f866c8dd811c9ed6339d9b3e353a4205a8aa8bbf/config/mergelists/canary.yaml#L13-L14) and [prod.yaml](https://github.com/kubernetes/test-infra/blob/f866c8dd811c9ed6339d9b3e353a4205a8aa8bbf/config/mergelists/prod.yaml#L13-L14).

### Open Collective

On 4 May 2022 we opened an [Open Collective account for the cert-manager organization][Open Collective cert-manager page]
in order to [manage the funds][GSoD: Grants for organizations] for our [Google Season of Docs 2022 project][].

We set up the account as an _Open Source Collective_,  with Open Collective as our fiscal host.
This means they hold funds on our behalf.
No fees from Open Source Collective will apply to our GSoD grant payment.
You can read more at [GSoD: Grants for organizations][].

At time of writing [Richard Wall](https://github.com/wallrj) and [Mael Valais](https://github.com/maelvls) are administrators.

[Open Collective cert-manager page]: https://opencollective.com/cert-manager
[Google Season of Docs 2022 project]: https://cert-manager.io/docs/contributing/google-season-of-docs/2022/improve-navigation-and-structure/index
[GSoD: Grants for organizations]: https://developers.google.com/season-of-docs/docs/org-payments
