data "aws_caller_identity" "current" {}

module "iam_role_lambda" {
  source             = "./role"
  role_name_suffix   = var.lambda_iam_role_name_suffix
  assume_role_policy = data.aws_iam_policy_document.lambda.json
  description        = var.description
  environment        = var.environment
  use_case           = var.use_case
}

module "iam_policy_lambda" {
  source             = "./policy"
  environment        = var.environment
  policy_name_suffix = var.lambda_iam_policy_name_suffix
  description        = var.description
  use_case           = var.use_case
  policy = templatefile("./policy/lambda_s3_policy.json", {
    environment = var.environment
    use_case    = var.use_case
    kms_key_arn = var.kms_key_arn
    account_id  = data.aws_caller_identity.current.account_id
    bucket_name = var.bucket_name
  })
}

module "iam_role_policy_attach_ecs" {
  source      = "./attach-policy"
  role_name   = module.iam_role_lambda.output_role.name
  policy_arns = module.iam_policy_lambda.output_policy.arn
  depends_on  = [module.iam_role_lambda, module.iam_policy_lambda]
}