output "output-lambda-role-s3" {
  value = {
    arn  = module.iam_role_lambda.output_role.arn
    name = module.iam_role_lambda.output_role.name
  }
}


