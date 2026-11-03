output "job_definition_arn" {
  description = "ARN of the created batch job definition"
  value       = aws_batch_job_definition.new_revision.arn
}

output "job_definition_name" {
  description = "Name of the created batch job definition"
  value       = aws_batch_job_definition.new_revision.name
}

output "job_definition_revision" {
  description = "Revision number of the created batch job definition"
  value       = aws_batch_job_definition.new_revision.revision
}

output "job_definition_tags" {
  description = "Tags applied to the batch job definition"
  value       = aws_batch_job_definition.new_revision.tags
}

output "created_at" {
  description = "When the inputs that define this revision last changed (RFC 3339)"
  value       = time_static.created_at.rfc3339
}
