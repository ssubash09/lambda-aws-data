# provider "aws" {
#   shared_config_files      = ["C:/Users/HP/.aws/config"]
#   shared_credentials_files = ["C:/Users/HP/.aws/credentials"]
#   profile                  = "default"
# }


provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = merge(
      local.common_tags,
      {
        region = "us-east-1"
      }
    )
  }
}