output "output_role" {
  value = {
    arn  = aws_iam_role.create_role.arn
    name = aws_iam_role.create_role.name
  }

}