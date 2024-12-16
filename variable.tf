variable "use_case" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "description" {
  type    = string
  default = "An example symmetric encryption KMS key"
}



############################################IAM############################

variable "lambda_iam_role_name_suffix" {}
variable "lambda_iam_policy_name_suffix" {}

############################################S3############################

variable "bucket_name" {
  description = "A unique name for your s3 name"
  type        = string
}

############################################SNS############################
variable "sns_topic_name" {
  description = "A unique name for your ec2 name"
  type        = string
}




variable "sns_email_subscription_list" {
  type = list(string)
}







