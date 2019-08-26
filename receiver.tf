resource "aws_api_gateway_rest_api" "MyDemoAPI" {
  name        = "MyDemoAPI"
  description = "This is my API for demonstration purposes"
}

resource "aws_lambda_function" "receiver_lambda" {
  filename = "receiver/receiver.zip"
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
