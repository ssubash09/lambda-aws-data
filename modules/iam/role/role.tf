resource "aws_iam_role" "create_role" {
  name               = "${var.use_case}-${var.environment}-${var.role_name_suffix}"
  description        = var.description
  assume_role_policy = var.assume_role_policy
}