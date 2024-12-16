variable "sns_topic_name" {
  description = "A unique name for your SNS name"
  type        = string
}

variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK"
  type        = string
}


variable "sns_email_subscription_list" {
  type = list(string)
}