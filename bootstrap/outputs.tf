
output "state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.tf_state.bucket
}

#the repo output
output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.customer_feedback.name
}
