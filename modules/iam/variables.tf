variable "use_case" {
  description = "use_case name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "description" {
  type    = string
  default = "IAM ROLE managed by Terraform"
}

variable "lambda_iam_role_name_suffix" {}
variable "lambda_iam_policy_name_suffix" {}
variable "kms_key_arn" {}

variable "bucket_name" {}