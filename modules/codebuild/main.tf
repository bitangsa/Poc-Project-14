data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
}

data "aws_iam_policy_document" "codebuild_policy" {

dynamic "statement" {
  for_each = var.policy_statements

  content {
    effect = statement.var.effect
    actions = statement.var.actions
    resources = statement.var.resources
  }
}

  # statement {
  #   effect = "Allow"

  #   actions = [ 
  #       "logs:CreateLogGroup",
  #       "logs:CreateLogStream",
  #       "logs:PutLogEvents"
  #    ]

  #    resources = ["*"]
  # }

  # statement {
  #   effect = "Allow"

  #   actions = [ 
  #       "s3:GetObject",
  #       "s3:PutObject",
  #       "s3:GetObjectVersion"
  #    ]

  #    resources = [ 
  #       var.artifacts_bucket_arn,
  #       "${var.artifacts_bucket_arn}/*"
  #     ]
  # }

}


resource "aws_iam_policy" "codebuild_policy" {
  name = "${var.project_name}-codebuild-policy"
  policy = data.aws_iam_policy_document.codebuild_policy.json
}

resource "aws_iam_role_policy_attachment" "codebuild_attach" {
  role = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

resource "aws_codebuild_project" "this" {
  name = "${var.project_name}-build"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type = "LINUX_CONTAINER"
    privileged_mode = false
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/codebuild/${var.project_name}-build"
      stream_name = "build"
    }
  }
  tags = {
    Name = var.project_name
  }
}