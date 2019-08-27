resource "aws_iam_role" "redshift_role" {
  name = "RedshiftRole"
  assume_role_policy = data.aws_iam_policy_document.redshift_assume_role.json
}

data "aws_iam_policy_document" "redshift_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "receiver_lambda_role" {
  name = "ReceiverLambdaRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_execution_policy" {
  # allow the lambda to write cloudwatch logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  # allow the lambda to put files into the receiver bucket
  statement {
    effect = "Allow"
    actions = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.receiver.bucket}/*"]
  }
}

resource "aws_iam_role_policy" "lambda_accesses_code_bucket" {
  name = "AllowsReceiverExecuton"
  role = aws_iam_role.receiver_lambda_role.id
  policy = data.aws_iam_policy_document.lambda_execution_policy.json
}
