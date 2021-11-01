module "terraform-aws-controlshift-redshift-sync" {
  source = "controlshift/controlshift-redshift-sync/aws"
  version = ">= 0.4.0"

  aws_region = var.aws_region
  controlshift_environment = var.controlshift_environment
  controlshift_hostname = var.controlshift_hostname
  controlshift_organization_slug = var.controlshift_organization_slug
  failed_manifest_prefix = var.failed_manifest_prefix
  failure_topic_name = var.failure_topic_name
  failure_topic_name_for_run_glue_job_lambda = var.failure_topic_name_for_run_glue_job_lambda
  glue_scripts_bucket_name = var.glue_scripts_bucket_name
  glue_physical_connection_requirements = var.glue_physical_connection_requirements
  manifest_bucket_name = var.manifest_bucket_name
  manifest_prefix = var.manifest_prefix
  receiver_timeout = var.receiver_timeout
  redshift_cluster_identifier = aws_redshift_cluster.default.id
  redshift_database_name = aws_redshift_cluster.default.database_name
  redshift_password = var.redshift_password
  redshift_schema = var.redshift_schema
  redshift_username = var.redshift_username
  success_topic_name = var.success_topic_name
  success_topic_name_for_run_glue_job_lambda = var.success_topic_name_for_run_glue_job_lambda
}
