data "archive_file" "receiver_zip" {
  type        = "zip"
  source_file = "${path.module}/receiver/receiver.js"
  output_path = "${path.module}/receiver/receiver.zip"
}

resource "aws_lambda_function" "receiver_lambda" {
  filename = data.archive_file.receiver_zip.output_path
  function_name = "recieve-webhook-handler"
  role          = aws_iam_role.receiver_lambda_role.arn
  handler       = "receiver.js"
  runtime = "nodejs10.x"

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.receiver.bucket
    }
  }
}
