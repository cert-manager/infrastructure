# cert-manager GCP infrastructure

This directory contains the Terraform configuration for the GCP infrastructure of the cert-manager project.
This infrastructure lives in the CNCF GCP organization under the `cert-manager` folder.

## Planning and applying changes

To plan changes to the infrastructure, run:

```shell
git clone https://github.com/cert-manager/infrastructure.git
tofu init
tofu plan
```

> :warning: If there are any uncommitted changes, make sure you understand who made them and why.
> We are still actively developing the infrastructure, so it's possible that there are
> changes and bugfixes that are not yet committed to the repository.

> :information_source: If you are not an admin (listed in the variables.tf file), you will not be able
> to access the terraform state bucket and the GCP projects.

To apply changes to the infrastructure, run:

```shell
tofu apply
```
