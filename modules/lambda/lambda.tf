resource "aws_lambda_function" "lambda" {
  filename         = var.filename
  function_name    = "lambda_function_s3_data_transmission"
  role             = var.iam_lambda_role
  layers           = var.layer_list
  timeout          = var.timeout
  memory_size      = var.memory_size
  runtime          = var.runtime
  publish          = true
  description      = var.description
  handler          = var.lambda_handler
  source_code_hash = var.source_code_hash

  environment {
    variables = {
      KMS_ARN       = var.kms_key_arn
      SNS_TOPIC_ARN = var.sns_arn
    }
  }
  kms_key_arn = var.kms_key_arn
}

resource "aws_lambda_alias" "lambda_alias" {
  name             = var.lambda_alias
  description      = "Alias '${var.lambda_alias}' to deploy a version of lambda"
  function_name    = aws_lambda_function.lambda.arn
  function_version = aws_lambda_function.lambda.version
  depends_on       = [aws_lambda_function.lambda]
  
}


resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFroms3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
  qualifier     = aws_lambda_alias.lambda_alias.name
}


resource "aws_s3_bucket_notification" "s3_bucket_notification" {
  bucket = var.bucket_id
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "csv_folder"
    filter_suffix       = ".csv"
  }
  depends_on = [aws_lambda_function.lambda, aws_lambda_permission.allow_s3]
}