output "topic_arn" {
  description = "The ARN of the SNS topic, as a more obvious property (clone of id)"
  value       = try(aws_sns_topic.sns_topic[0].arn, null)
}