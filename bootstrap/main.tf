#import s3 bucket
import {
  to = aws_s3_bucket.tf_state
  id = var.state_bucket_name
}



#create terraform ecr
resource "aws_ecr_repository" "customer_feedback" {
  name                 = "customer-feedback"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
