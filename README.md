# Terraform AWS AWS Batch Job Revision

[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/modules/YauhenBichel/batch-job-revision/aws/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Creates a new revision of an AWS Batch job definition — Fargate or EC2, with configurable vCPU, memory, image and IAM roles. Registering a new revision on each deploy keeps previous revisions intact so a rollback is a one-line change.

## Usage

```hcl
module "batch_job_revision" {
  source  = "YauhenBichel/batch-job-revision/aws"
  version = "1.1.0"

  env                 = "prod"
  service_domain      = "payments"
  team                = "infra-team"
  aws_region          = "eu-west-1"

  job_definition_name = "nightly-reconciliation"
  image_name          = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/recon:1.4.2"
  platform_capability = "FARGATE"
  vcpu                = "0.5"
  memory              = "1024"

  # Two different roles, one letter apart. execution_role is the job role the
  # container assumes; execution_role_arn is the role Batch itself uses to
  # pull the image and write logs.
  execution_role      = aws_iam_role.batch_job.arn
  execution_role_arn  = aws_iam_role.batch_execution.arn
}
```

## Provider configuration

This module does not declare its own `provider` block — the caller supplies it. That keeps the
module usable with `count`, `for_each` and `depends_on`, which Terraform forbids for modules
carrying their own provider configuration.

Configure the AWS provider in your root module, and use `default_tags` there if you want tags
applied across every resource:

```hcl
provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      Admin-Environment   = "prod"
      Admin-ServiceDomain = "payments"
      Team                = "infra-team"
    }
  }
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.0 |
| aws provider | ~> 6.0 |

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `env` | `string` | — | Environment being deployed to |
| `service_domain` | `string` | — | Namespaces deployments in a shared account |
| `job_definition_name` | `string` | — | Name of the Batch job definition |
| `image_name` | `string` | — | Container image URI |
| `execution_role` | `string` | — | **Job role.** The role the container assumes at run time (`jobRoleArn`) |
| `execution_role_arn` | `string` | — | **Execution role.** The role Batch uses to pull the image and write logs (`executionRoleArn`) |
| `team` | `string` | `infra-team` | Owning team |
| `aws_region` | `string` | `eu-west-1` | Target region |
| `job_revision_type` | `string` | `container` | Job definition type |
| `platform_capability` | `string` | `FARGATE` | `FARGATE` or `EC2` |
| `vcpu` | `string` | `0.25` | vCPU reservation |
| `memory` | `string` | `512` | Memory reservation in MiB |
| `fargate_platform_version` | `string` | `LATEST` | Fargate platform version |
| `fargate_platform_operating_system_family` | `string` | `LINUX` | Runtime OS family |
| `fargate_platform_cpu_architecture` | `string` | `X86_64` | Runtime CPU architecture |
| `assign_public_ip` | `string` | `ENABLED` | Whether the task gets a public IP |
| `job_command` | `list(string)` | `[]` | Overrides the image command |
| `environment_variables_list` | `list(object)` | `[]` | Environment variables, each `{ name, value }`. An empty `value` falls back, see below |
| `secrets_list` | `list(object)` | `[]` | Secrets, each `{ name, valueFrom }`, resolved from Parameter Store or Secrets Manager |
| `execution_timeout` | `number` | `3600` | Job timeout in seconds |
| `retry_attempts` | `number` | `1` | Retry attempts |
| `additional_tags` | `map(string)` | `{}` | Extra tags merged onto the job definition |
| `load_date` | `string` | `""` | Value used for the `LOAD_DATE` fallback |
| `load_date_default_enabled` | `bool` | `false` | `true` makes `LOAD_DATE` available as a fallback value |

A dash in the Default column means the input is required.

### Empty environment variables fall back

An entry in `environment_variables_list` whose `value` is `""` is filled from a
small set of computed values instead. `CREATED_AT` is one of them, and it is
built from `timestamp()`, which Terraform evaluates on every plan. So an entry
named `CREATED_AT` with an empty value shows a change on every single plan,
whether or not anything else moved. Give it a real value if you do not want
that. `LOAD_DATE` is the other, and only when `load_date_default_enabled` is
`true`.

## Outputs

| Name | Description |
|---|---|
| `job_definition_arn` | ARN of the new job definition revision |
| `job_definition_name` | Name of the job definition |
| `job_definition_revision` | Revision number just registered |
| `job_definition_tags` | Tags applied to the revision |

## Contributing

Issues and pull requests are welcome. Please open an issue describing the problem before
sending a large change.

## Licence

[MIT](LICENSE) — Yauhen Bichel

---

## Contributors

Thank you to everyone who has helped.

<!-- readme: contributors,bots/- -start -->
<!-- readme: contributors,bots/- -end -->

Filled from GitHub commits (bots omitted). Live demo: [readme-contributors](https://github.com/YauhenBichel/readme-contributors#live-demo).
