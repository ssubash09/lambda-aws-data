resource "aws_s3_bucket" "terraformbucket" {
  bucket = "lambda-${var.use_case}-${var.environment}-${var.bucket_name}"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.kms_key_id
      }
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  bucket = aws_s3_bucket.terraformbucket.id

  rule {
    id     = "log"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_control" {
  bucket = aws_s3_bucket.terraformbucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "acl" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_control]

  bucket = aws_s3_bucket.terraformbucket.id
  acl    = var.acl
}

resource "aws_s3_object" "csv_file" {
  bucket       = aws_s3_bucket.terraformbucket.id
  key          = "csv_folder/lambda_data_transformation.csv"
  source       = "${path.root}/sample_test.csv"
  content_type = "text/csv"
  kms_key_id   = var.kms_key_id
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.terraformbucket.id
  policy = data.aws_iam_policy_document.bucket_policy_document.json
}

data "aws_iam_policy_document" "bucket_policy_document" {
  source_policy_documents = [templatefile("./policy/bucket_policy.json", {
    bucket_name = var.bucket_name
    environment = var.environment
    use_case    = var.use_case
  })]
}
