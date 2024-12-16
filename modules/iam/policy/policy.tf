resource "aws_iam_policy" "create_policy" {
  name        = "${var.use_case}-${var.environment}-${var.policy_name_suffix}"
  description = var.description
  policy      = var.policy
}