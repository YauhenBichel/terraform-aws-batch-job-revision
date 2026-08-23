# Terraform AWS AWS Batch Job Revision

[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/modules/YauhenBichel/batch-job-revision/aws/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Creates a new revision of an AWS Batch job definition — Fargate or EC2, with configurable vCPU, memory, image and IAM roles. Registering a new revision on each deploy keeps previous revisions intact so a rollback is a one-line change.

## Usage

```hcl
module "batch_job_revision" {
  source  = "YauhenBichel/batch-job-revision/aws"
  version = "1.0.0"

  env                 = "prod"
  service_domain      = "payments"
  team                = "infra-team"
  aws_region          = "eu-west-1"

  job_definition_name = "nightly-reconciliation"
  image_name          = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/recon:1.4.2"
  platform_capability = "FARGATE"
  vcpu                = "0.5"
  memory              = "1024"
  execution_role_arn  = aws_iam_role.batch_execution.arn
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.0 |
| aws provider | >= 4.0 |

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `env` | `string` | — | Environment being deployed, e.g. `dev`, `prod` |
| `service_domain` | `string` | — | Namespaces deployments in a shared account |
| `team` | `string` | `infra-team` | Owning team, applied as a tag |
| `aws_region` | `string` | `eu-west-1` | Target region |
| `job_definition_name` | `string` | — | Name of the AWS Batch job definition |
| `job_revision_type` | `string` | `container` | Type of the batch job revision |
| `platform_capability` | `string` | `FARGATE` | `FARGATE` or `EC2` |
| `image_name` | `string` | — | Container image for the job |
| `vcpu` | `string` | `0.25` | vCPUs allocated |
| `memory` | `string` | `512` | Memory in MB |
| `execution_role_arn` | `string` | — | Execution role ARN |

A dash in the Default column means the input is required.

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
