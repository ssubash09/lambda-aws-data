data "aws_caller_identity" "current" {}

resource "aws_kms_key" "kms" {
  description              = var.description
  enable_key_rotation      = var.enable_key_rotation
  deletion_window_in_days  = var.deletion_window_in_days
  customer_master_key_spec = var.customer_master_key_spec
  key_usage                = var.key_usage


  policy = templatefile("./policy/kms_key_policy.json",
    {
      environment = var.environment
      use_case    = var.use_case
      account_id  = data.aws_caller_identity.current.account_id

    }
  )
}

resource "aws_kms_alias" "kms_alias" {
  name          = "alias/${var.use_case}-${var.environment}-${var.kms_key}"
  target_key_id = join("", aws_kms_key.kms.*.id)

}