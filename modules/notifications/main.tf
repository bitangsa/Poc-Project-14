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

resource "aws_iam_role" "eventbridge_invoke_sns" {
  name = "${var.project_name}-ev2sns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge_invoke_sns_policy" {
  name = "${var.project_name}-ev2sns-policy"
  role = aws_iam_role.eventbridge_invoke_sns.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["sns:Publish"]
        Resource = aws_sns_topic.pipeline_notifications.arn
      }
    ]
  })
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


# resource "aws_cloudwatch_event_target" "codepipeline_to_sns" {
#   rule = aws_cloudwatch_event_rule.codepipeline_state_change.name
#   arn  = aws_sns_topic.pipeline_notifications.arn
# }

resource "aws_cloudwatch_event_target" "codepipeline_to_sns" {
  rule     = aws_cloudwatch_event_rule.codepipeline_state_change.name
  arn      = aws_sns_topic.pipeline_notifications.arn
  role_arn = aws_iam_role.eventbridge_invoke_sns.arn

  input_transformer {
    input_paths = {
      pipeline   = "$.detail.pipeline"
      state      = "$.detail.state"
      exec_id    = "$.detail['execution-id']"
      region     = "$.region"
      time       = "$.time"
      account    = "$.account"
    }

    input_template = <<TEMPLATE
{
  "default": "CodePipeline Notification\n\nPipeline : <pipeline>\nState    : <state>\nExecution: <exec_id>\nTime     : <time>\nRegion   : <region>\nConsole  : https://console.aws.amazon.com/codesuite/codepipeline/pipelines/<pipeline>/executions/<exec_id>/timeline\n\n(You are receiving this because you subscribed to ${var.project_name} notifications.)"
}
TEMPLATE
  }
}