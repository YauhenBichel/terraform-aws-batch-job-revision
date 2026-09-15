variable "env" {
  description = "The environment being deployed"
  type        = string
  nullable    = false
}

variable "service_domain" {
  description = "Used to help create namespaced deployments in case of shared account."
  type = string
  nullable = false
}

variable "team" {
  default     = "infra-team"
  description = "Team"
  type = string
  nullable = false
}


variable "aws_region" {
  default     = "eu-west-1"
  description = "Where this will be deployed to"
  type = string
  nullable = false
}

# AWS Batch Job Revision

variable "job_definition_name" {
  description = "Name of the AWS Batch job definition"
  type        = string
}

variable "job_revision_type" {
  description = "Type of the batch job revision"
  type        = string
  default     = "container"
}

variable "platform_capability" {
  description = "Platform capability for the batch job"
  type        = string
  default     = "FARGATE"
}

variable "image_name" {
  description = "Docker image name for the batch job"
  type        = string
}

variable "vcpu" {
  description = "Number of vCPUs for the batch job"
  type        = string
  default     = "0.25"
}

variable "memory" {
  description = "Memory allocation for the batch job in MB"
  type        = string
  default     = "512"
}

variable "execution_role" {
  description = "Job role ARN for the batch job"
  type        = string
}

variable "execution_role_arn" {
  description = "Execution role ARN for the batch job"
  type        = string
}

variable "fargate_platform_version" {
  description = "Fargate platform version"
  type        = string
  default     = "LATEST"
}

variable "fargate_platform_operating_system_family" {
  description = "Operating system family for Fargate platform"
  type        = string
  default     = "LINUX"
}

variable "fargate_platform_cpu_architecture" {
  description = "CPU architecture for Fargate platform"
  type        = string
  default     = "X86_64"
}

variable "assign_public_ip" {
  description = "Whether to assign public IP to the batch job"
  type        = string
  default     = "ENABLED"
}

variable "job_command" {
  description = "Command to run in the batch job container"
  type        = list(string)
  default     = []
}

variable "environment_variables_list" {
  description = "List of environment variables for the batch job"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "secrets_list" {
  description = "List of secrets for the batch job"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "execution_timeout" {
  description = "Execution timeout in seconds"
  type        = number
  default     = 3600
}

variable "retry_attempts" {
  description = "Number of retry attempts"
  type        = number
  default     = 1
}

variable "additional_tags" {
  description = "Additional tags to apply to the batch job definition"
  type        = map(string)
  default     = {}
}


variable "load_date" {
  description = "Load date for fallback"
  type        = string
  default     = ""
}

variable "load_date_default_enabled" {
  default     = false
  description = "Enable default date (today and now) for LOAD_DATE: if false, then LOAD_DATE value is empty string"
  type = bool
}