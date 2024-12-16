################################################################################
# Topic
################################################################################

resource "aws_sns_topic" "sns_topic" {
  count             = var.create ? 1 : 0
  name              = var.sns_topic_name
  kms_master_key_id = var.kms_master_key_id
}

################################################################################
# Subscription(s)
################################################################################

resource "aws_sns_topic_subscription" "this" {
  count     = length(var.sns_email_subscription_list)
  endpoint  = var.sns_email_subscription_list[count.index]
  protocol  = "email"
  topic_arn = aws_sns_topic.sns_topic[0].arn
}

