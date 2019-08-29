resource "aws_dynamodb_table" "loader_config" {
  name  = "LambdaRedshiftBatchLoadConfig"
  billing_mode = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 5

  attribute {
    name = "s3Prefix"
    type = "S"
  }

  hash_key = "s3Prefix"
}

resource "aws_dynamodb_table_item" "load_signatures" {
  table_name = aws_dynamodb_table.loader_config.name
  hash_key   = aws_dynamodb_table.loader_config.hash_key

  item = data.template_file.loader_config_item.rendered
}

data "template_file" "loader_config_item" {
  template = "${file("${path.module}/config_item.json")}"
  vars = {
    redshift_endpoint = aws_redshift_cluster.default.dns_name
    redshift_database_name: aws_redshift_cluster.default.database_name
    redshift_port = aws_redshift_cluster.default.port
    redshift_username = aws_redshift_cluster.default.master_username
    redshift_password = aws_kms_ciphertext.redshift_password.ciphertext_blob
    s3_bucket = aws_s3_bucket.receiver.bucket
    manifest_bucket = aws_s3_bucket.manifest.bucket
    manifest_prefix = var.manifest_prefix
    failed_manifest_prefix = var.failed_manifest_prefix
    current_batch = random_id.current_batch.b64_url
  }
}

resource "random_id" "current_batch" {
  byte_length = 16
}

resource "aws_kms_ciphertext" "redshift_password" {
  key_id = aws_kms_key.lambda_config.key_id
  context = {
    module = "AWSLambdaRedshiftLoader",
    region = var.aws_region
  }
plaintext = aws_redshift_cluster.default.master_password
}

resource "aws_kms_alias" "lambda_alias" {
  name = "alias/LambaRedshiftLoaderKey"
  target_key_id = aws_kms_key.lambda_config.key_id
}

resource "aws_kms_key" "lambda_config" {
  description = "Lambda Redshift Loader Master Encryption Key"
  is_enabled  = true
}

