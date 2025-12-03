data "aws_iam_policy_document" "codepipeline_assume" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.project_name}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume.json
}

data "aws_iam_policy_document" "codepipeline_policy" {

  dynamic "statement" {
  for_each = var.policy_statements

  content {
    effect = statement.value.effect
    actions = statement.value.actions
    resources = statement.value.resources
  }
}
  # statement {
  #   effect = "Allow"

  #   actions = [
  #     "s3:GetObject",
  #     "s3:GetObjectVersion",
  #     "s3:PutObject"
  #   ]

  #   resources = [
  #     var.artifacts_bucket_arn,
  #     "${var.artifacts_bucket_arn}/*"
  #   ]
  # }

  # statement {
  #   effect = "Allow"

  #   actions = [
  #     "codebuild:StartBuild",
  #     "codebuild:BatchGetBuilds"
  #   ]

  #   resources = [
  #     var.codebuild_project_arn
  #   ]
  # }
}

data "aws_iam_policy_document" "codepipeline_codedeploy" {
  statement {
    effect = "Allow"

    actions = [
      "codedeploy:RegisterApplicationRevision",
      "codedeploy:CreateDeployment",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:GetApplication",
      "codedeploy:GetDeploymentGroup",
      "codedeploy:*"
    ]

    resources = ["*"]

    # resources = [
    #   "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:application:${var.codedeploy_app_name}",
    #   "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:deploymentgroup:${var.codedeploy_app_name}/${var.codedeploy_deployment_group_name}",
    #   "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:deploymentconfig:*"
    # ]
  }
}

resource "aws_iam_role_policy" "codepipeline_codedeploy" {
  name   = "${var.project_name}-codepipeline-codedeploy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_codedeploy.json
}


# resource "aws_iam_role_policy_attachment" "codepipeline_codedeploy_managed" {
#   role       = aws_iam_role.codepipeline_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForCodePipeline"
# }

resource "aws_iam_policy" "codepipeline_policy" {
  name = "${var.project_name}-codepipeline-policy"
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_attach" {
  role = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

resource "aws_codepipeline" "this" {
  name = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type = "S3"
    location = var.artifacts_bucket_name
  }
  stage {
    name = "Source"
    action {
      name = "GitHub_Source"
      category = "Source"
      owner = "ThirdParty"
      provider = "GitHub"
      version = "1"

      output_artifacts = ["source_output"]

      configuration = {
        Owner = var.github_owner
        Repo = var.github_repo
        Branch = var.github_branch
        OAuthToken = var.github_oauth_token
        PollForSourceChanges = "false"
    }
  }

}  
stage {
    name = "Build"

    action {
      name = "CodeBuild"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"

      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }

 }

# stage {
#     name = "Deploy"

#     action {
#       name            = "Deploy"
#       category        = "Deploy"
#       owner           = "AWS"
#       provider        = "CodeDeploy"
#       version         = "1"
#       input_artifacts = ["BuildOutput"]

#       configuration = {
#         ApplicationName     = var.codedeploy_app_name
#         DeploymentGroupName = var.codedeploy_deployment_group_name
#       }
#     }
#   }

  stage {
    name = "Deploy"

    action {
      name            = "CodeDeploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"

      input_artifacts  = ["build_output"]   # from Build stage
      output_artifacts = []

      configuration = {
        ApplicationName     = var.codedeploy_app_name
        DeploymentGroupName = var.codedeploy_deployment_group_name
      }
    }
  }

 tags = {
   Project = var.project_name
 }
}

resource "aws_codepipeline_webhook" "github" {
  name = "${var.project_name}-github-webhook"
  authentication = "GITHUB_HMAC"
  target_pipeline = aws_codepipeline.this.name
  target_action = "GitHub_Source"

  authentication_configuration {
    secret_token = var.github_webhook_secret
  }

  filter {
    json_path = "$.ref"
    match_equals = "refs/heads/${var.github_branch}"
  }
}
