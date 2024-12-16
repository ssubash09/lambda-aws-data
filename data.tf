data "archive_file" "lambda_func_s3_zip" {
  type        = "zip"
  output_path = "lambda-s3.zip"
  source_dir  = "${path.module}/code/lambda-s3"
}

