variable "acl" {
  default = "private"
}


variable "bucket_name" {
  description = "A unique name for your s3 name"
  type        = string
}

variable "environment" {
  description = "SDLC Environment name"
  type        = string
}


variable "use_case" {
  description = "use_case name"
  type        = string
}

variable "kms_key_id" {}