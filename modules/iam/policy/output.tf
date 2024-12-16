output "output_policy" {
  value = {
    arn  = aws_iam_policy.create_policy.arn
    name = aws_iam_policy.create_policy.name
  }

}