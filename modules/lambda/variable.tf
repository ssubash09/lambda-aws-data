variable "description" {
  type    = string
  default = "lambda fucntion managed by terraform"

}

variable "iam_lambda_role" {
  description = "ARN of the IAM role for the Lambda function"
  type        = string
}

variable "layer_list" {
  description = "List of Lambda layers to attach"
  type        = list(string)
  default     = null
}

variable "timeout" {
  description = "Timeout for the Lambda function (in seconds)"
  type        = number
  default     = 900
}

variable "memory_size" {
  description = "Memory size for the Lambda function (in MB)"
  type        = number
  default     = 256
}

variable "runtime" {
  description = "Runtime for the Lambda function, e.g., python3.9 or nodejs18.x"
  type        = string
  default     = "python3.11"
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to use for encryption"
  type        = string
}

variable "sns_arn" {
  description = "ARN of the SNS topic"
  type        = string
}

variable "python_version" {
  default = "python3.11"
}

variable "lambda_alias" {
  description = "Name of the Lambda alias"
  type        = string
  default     = "test"
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket that triggers the Lambda function"
  type        = string
}

variable "bucket_id" {
  description = "Name of the S3 bucket"
  type        = string
}


variable "filename" {
  description = "Name of the lambda function"
  type        = string
}

variable "source_code_hash" {}

variable "lambda_handler" {
  type    = string
  default = "lambda_function.lambda_handler"
}