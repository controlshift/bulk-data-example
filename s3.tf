resource "aws_s3_bucket" "receiver" {
  bucket = var.receiver_bucket_name
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    Name        = "ControlShift dumps CSVs here"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "lambda_code" {
  bucket = var.lambdas_bucket_name
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    Name = "s3 bucket for storing lambda code"
  }
}

resource "aws_s3_bucket_object" "receiver" {
  bucket = aws_s3_bucket.lambda_code.bucket
  key    = "receiver.js"
  source = "receiver/receiver.js"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("receiver/receiver.js")
}


