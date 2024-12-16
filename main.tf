module "kms" {
  source      = "./modules/kms"
  use_case    = var.use_case
  environment = var.environment
}

module "iam" {
  source                        = "./modules/iam"
  use_case                      = var.use_case
  environment                   = var.environment
  lambda_iam_policy_name_suffix = var.lambda_iam_policy_name_suffix
  lambda_iam_role_name_suffix   = var.lambda_iam_role_name_suffix
  kms_key_arn                   = module.kms.kms_arn
  bucket_name = module.s3.s3_bucket_id
}

module "s3" {
  source      = "./modules/s3-bucket"
  use_case    = var.use_case
  environment = var.environment
  bucket_name = var.bucket_name
  kms_key_id  = module.kms.kms_arn
  depends_on  = [module.kms]
}

module "sns" {
  source                      = "./modules/sns"
  kms_master_key_id           = module.kms.kms_arn
  sns_topic_name              = var.sns_topic_name
  sns_email_subscription_list = var.sns_email_subscription_list
}


module "lambda" {
  source           = "./modules/lambda"
  s3_bucket_arn    = module.s3.s3_bucket_arn
  iam_lambda_role  = module.iam.output-lambda-role-s3.arn
  sns_arn          = module.sns.topic_arn
  filename         = data.archive_file.lambda_func_s3_zip.output_path
  kms_key_arn      = module.kms.kms_arn
  bucket_id        = module.s3.s3_bucket_id
  source_code_hash = data.archive_file.lambda_func_s3_zip.output_base64sha256
}