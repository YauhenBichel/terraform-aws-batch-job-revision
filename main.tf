terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
  }
}

# timestamp() changes on every run, so using it here registered a new revision on every apply.
# This value only changes when an input that defines the revision changes.
resource "time_static" "created_at" {
  triggers = {
    job_definition_name = var.job_definition_name
    image_name          = var.image_name
    vcpu                = var.vcpu
    memory              = var.memory
    environment         = jsonencode(var.environment_variables_list)
  }
}

locals {
  fallback_variables = merge(
    {
      "CREATED_AT"            = formatdate("YYYY-MM-DD'T'HH:mm:ss", time_static.created_at.rfc3339)
    },
    var.load_date_default_enabled ? 
    {
      "LOAD_DATE"             = var.load_date
    }
    :
    {}
  )

  env_variables_with_fallback = [
    for item in var.environment_variables_list : {
      name  = item.name
      value = item.value != "" ? item.value : lookup(local.fallback_variables, item.name, "")
    }
  ]
}

resource "aws_batch_job_definition" "new_revision" {
  name = var.job_definition_name
  type = var.job_revision_type

  platform_capabilities = [var.platform_capability]

  container_properties = jsonencode({
    image = var.image_name

    resourceRequirements = [
      {
        type  = "VCPU"
        value = var.vcpu
      },
      {
        type  = "MEMORY"
        value = var.memory
      }
    ]

    jobRoleArn       = var.execution_role
    executionRoleArn = var.execution_role_arn

    fargatePlatformConfiguration = {
      platformVersion = var.fargate_platform_version
    }

    runtimePlatform = {
      operatingSystemFamily = var.fargate_platform_operating_system_family
      cpuArchitecture       = var.fargate_platform_cpu_architecture
    }

    networkConfiguration = {
      assignPublicIp = var.assign_public_ip
    }

    command = var.job_command

    environment = [
      for item in local.env_variables_with_fallback : {
        name  = item.name
        value = item.value
      }
    ]

    secrets = [
      for item in var.secrets_list : {
        name      = item.name
        valueFrom = item.valueFrom
      }
    ]
  })

  timeout {
    attempt_duration_seconds = var.execution_timeout
  }

  retry_strategy {
    attempts = var.retry_attempts
  }

  tags = merge(
    {
      ManagedBy = "Terraform"
    },

    var.additional_tags
  )
}