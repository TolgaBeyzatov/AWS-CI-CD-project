# Listing the aws IAM User name

resource "aws_iam_user" "iam_user" {
  name = "terraadmin"
}


# Policy for ECR access #

data "aws_iam_policy_document" "ecr" {
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage"
    ]
    resources = [
      aws_ecr_repository.actapp.arn
    ]
  }
}

resource "aws_iam_policy" "ecr" {
  name        = "${aws_iam_user.iam_user.name}-ecr"
  description = "Allow user to manage ECR resources"
  policy      = data.aws_iam_policy_document.ecr.json
}

resource "aws_iam_user_policy_attachment" "ecr" {
  user       = aws_iam_user.iam_user.name
  policy_arn = aws_iam_policy.ecr.arn
}