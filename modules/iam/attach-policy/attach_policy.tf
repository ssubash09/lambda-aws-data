resource "aws_iam_role_policy_attachment" "attach_role_policies" {
  role       = var.role_name
  policy_arn = var.policy_arns
}