# Runs offline: terraform test. The AWS provider is mocked, so no credentials are needed.

mock_provider "aws" {}

variables {
  env                 = "dev"
  service_domain      = "example"
  team                = "example"
  job_definition_name = "example"
  image_name          = "example:1"
  execution_role      = "arn:aws:iam::123456789012:role/job"
  execution_role_arn  = "arn:aws:iam::123456789012:role/execution"
  environment_variables_list = [
    { name = "CREATED_AT", value = "" },
    { name = "STAGE", value = "test" },
  ]
}

run "first_apply" {
  command = apply
}

# A plan with the same inputs must see the same CREATED_AT: timestamp() would be unknown here.
run "same_inputs_keep_created_at" {
  command = plan

  assert {
    condition = (
      [for e in jsondecode(aws_batch_job_definition.new_revision.container_properties).environment : e.value if e.name == "CREATED_AT"][0]
      == formatdate("YYYY-MM-DD'T'HH:mm:ss", run.first_apply.created_at)
    )
    error_message = "CREATED_AT changed although no input did"
  }
}

run "set_value_wins_over_the_fallback" {
  command = plan

  variables {
    environment_variables_list = [{ name = "CREATED_AT", value = "fixed" }]
  }

  assert {
    condition     = jsondecode(aws_batch_job_definition.new_revision.container_properties).environment[0].value == "fixed"
    error_message = "A value set by the caller must be kept"
  }
}
