data "aws_iam_policy_document" "lambda" {
  statement {
    sid     = "lambdaassumerole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


