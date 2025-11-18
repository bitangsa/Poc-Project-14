output "sns_topic_arn" {
  value = aws_sns_topic.pipeline_notifications.arn
}

output "event_rule_name" {
  value = aws_cloudwatch_event_rule.codepipeline_state_change.name
}
