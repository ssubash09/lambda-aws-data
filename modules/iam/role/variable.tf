variable "use_case" {
  description = "use_case_name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}


variable "assume_role_policy" {
  type        = any
  description = " assume policy document accepts json format"
}

variable "description" {
  type    = string
  default = "IAM ROLE managed by Terraform"
}

variable "role_name_suffix" {
  type = string
}