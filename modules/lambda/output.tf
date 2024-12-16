output "output_lambda" {
  value = {
    arn           = aws_lambda_function.lambda.arn
    Invoke_arn    = aws_lambda_function.lambda.invoke_arn
    qualified_arn = aws_lambda_function.lambda.qualified_arn
    function_name = aws_lambda_function.lambda.function_name
  }
}