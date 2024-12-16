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

variable "customer_master_key_spec" {
  default = "SYMMETRIC_DEFAULT"
}

variable "deletion_window_in_days" {
  default = 07
}

variable "enable_key_rotation" {
  type    = bool
  default = true
}

variable "key_usage" {
  default = "ENCRYPT_DECRYPT"
}

variable "kms_key" {
  type    = string
  default = "master-key"
}