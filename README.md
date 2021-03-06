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

Here, we list any services we know about and the method by which we change / configure / interact
with those services.

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

### Slack

We have 2 Slack channels on Kubernetes slack:

- [`cert-manager`](https://kubernetes.slack.com/archives/C4NV3DWUC) for user questions, chat and support
- [`cert-manager-dev`](https://kubernetes.slack.com/archives/CDEQJ0Q8M) for discussion on cert-manager development.

Administration of both is done by Kubernetes slack admins.

Maintainers should also have access to the [CNCF slack](https://cloud-native.slack.com/archives/C08PSKWQL), although this isn't used much.

### Netlify

We currently have two Netlify sites, both on different accounts.

`cert-manager.netlify.app` is the main Netlify site and is tied to Jetstack's organizational account. The cert-manager maintainers at
Jetstack can get access but this isn't available to open-source maintainers outside of Jetstack because the same org account is used
for other Jetstack-internal sites.

We will migrate away from the Jetstack org when possible.

The Jetstack account is used to publish the website on <https://cert-manager.io>. It also creates a preview site for PRs that are opened
against the `master` branch; the preview link can be seen in the GitHub checks at the bottom of the PR UI. It is configured though
through the Netlify console UI and also through the website repository (`_redirects` file).

Our secondary account is `cert-manager-website.netlify.app`, which will be the destination for the site after it's moved away from the
Jetstack org. This account's credentials are stored in Jetstack 1password and all Jetstack cert-manager maintainers have access to this
account. Credentials will be moved into a more open-source-friendly location along with other credentials.

### Algolia

Provides an API for searching the cert-manager website. We're in [DocSearch](https://docsearch.algolia.com/docs/what-is-docsearch/)
which is Algolia's free tool provided open-source projects.

The cert-manager maintainers have access to configure Algolia. Access is managed manually and can be granted by another maintainer.

Configured here: [https://crawler.algolia.com/admin/crawlers](https://crawler.algolia.com/admin/crawlers)

The Algolia app (Team, API Keys) can be configured here: [https://www.algolia.com/apps/01YP6XYAE7/dashboard](https://www.algolia.com/apps/01YP6XYAE7/dashboard)

The Algolia API Key must be configured as an environment variable in Netlify.

The other Algolia settings can be configured here: [https://github.com/cert-manager/website/blob/master/netlify.toml](https://github.com/cert-manager/website/blob/master/netlify.toml)

### Google Cloud Platform

Hosts test infrastructure, release infrastructure, past releases, and DNS for our domains.

- Testing infrastructure is currently in Jetstack's org. Will be rebuilt in the CNCF GCP org.
- Release infrastructure (under the `cert-manager-release` project) is in the Jetstack org, but CNCF's billing account. Org migration is [ongoing](https://github.com/cert-manager/release/issues/50).
- DNS is currently in Jetstack's org under the cert-manager-io project. Should be moved to CNCF.

### GitHub Org

The [cert-manager GitHub org](https://github.com/cert-manager/) holds all project repos. Configuration is done by admins, and the list of admins should
match the membership of the cert-manager-maintainers Google group.

We also have a bot - `jetstack-bot` - with high levels of access to the cert-manager org. It may have been manually set up and might require further documentation to
detail what it does, what it requires and why we have it.

### CNCF Maintainers

At the very least, all recognised cert-manager maintainers should be listed in the CNCF [`project-maintainers.csv`](https://github.com/cncf/foundation/blob/main/project-maintainers.csv).

This can be added to by existing maintainers, such as in [this PR](https://github.com/cncf/foundation/pull/213).

There are also CNCF mailing lists, although we don't currently have an exhaustive list of which ones are relevant.

### `@CertManager` Twitter Account

This twitter account isn't currently used, but it exists and we have access to it if we want to start using it.

As with other accounts, twitter credentials are currently stored in Jetstack password managers and will have to be moved to
an open-source solution.

### cert-manager YouTube Account

All cert-manager maintainers should be able to access the cert-manager [brand YouTube account](https://www.youtube.com/channel/UCNPMkzGrAsQxVUFMPn7n88Q)
if desired. Access is managed by existing maintainers who can administer that account by visiting the
[Brand Accounts](https://myaccount.google.com/brandaccounts) page.

Note that to upload videos or do other actions, you need to click on your profile in the top right of YouTube
and "switch account" to the cert-manager brand account.

### Zapier account

> **Updated 30 June 2022:** Mael disabled zap (1) and (2). Both zaps are constantly failing
> ([example email](https://groups.google.com/g/cert-manager-maintainers/c/-EfO3ar03vI)) with the
> message "you have exceeded your quota". Zapier is on it.

The zapier account has two zaps:

1. _Upload new Google Drive videos that are copied into 'mael-zapier-upload-to-youtube' to the cert-manager YouTube channel_, and
2. _Send a message on Slack (#cert-manager) when a new video is uploaded to the cert-manager Youtube channel_.

As with other accounts, zapier credentials are currently stored in Jetstack password managers and will have to be moved to
an open-source solution.

### TestGrid

Testgrid is hosted [here](https://testgrid.k8s.io/jetstack-cert-manager-master) under the old org name.
Configuration is updated with PRs like [this one](https://github.com/kubernetes/test-infra/pull/25229), which are generated
by [this prow job](https://github.com/jetstack/testing/blob/b6fea2453d244c7803c59ad2b155e4c4c8ac021f/config/jobs/testing/testing-trusted.yaml#L63-L89).

There's also testgrid config in the [testing repo](https://github.com/jetstack/testing/blob/b6fea2453d244c7803c59ad2b155e4c4c8ac021f/config/testgrid/dashboards.yaml).

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
