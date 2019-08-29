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
    redshift_endpoint = aws_redshift_cluster.default.endpoint
    redshift_port = aws_redshift_cluster.default.port
    redshift_username = aws_redshift_cluster.default.master_username
    redshift_password = aws_redshift_cluster.default.master_password
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
