output "kms_id" {
  value = aws_kms_key.kms.key_id
}

output "kms_arn" {
  value = aws_kms_key.kms.arn
}