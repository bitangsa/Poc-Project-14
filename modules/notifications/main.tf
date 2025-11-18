resource "aws_sns_topic" "pipeline_notifications" {
  name = "${var.project_name}-pipeline-notifications"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.pipeline_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

data "aws_iam_policy_document" "sns_pipeline_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.pipeline_notifications.arn]
  }
}

resource "aws_sns_topic_policy" "pipeline_notifications" {
  arn    = aws_sns_topic.pipeline_notifications.arn
  policy = data.aws_iam_policy_document.sns_pipeline_policy.json
}

resource "aws_cloudwatch_event_rule" "codepipeline_state_change" {
  name = "${var.project_name}-codepipeline-state-change"

  event_pattern = jsonencode({
    "source" : ["aws.codepipeline"],
    "detail-type" : ["CodePipeline Pipeline Execution State Change"],
    "detail" : {
      "pipeline" : [var.pipeline_name],
      "state" : ["SUCCEEDED", "FAILED"]
    }
  })
}


resource "aws_cloudwatch_event_target" "codepipeline_to_sns" {
  rule = aws_cloudwatch_event_rule.codepipeline_state_change.name
  arn  = aws_sns_topic.pipeline_notifications.arn
}
