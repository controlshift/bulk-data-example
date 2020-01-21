module "terraform-aws-controlshift-redshift-sync" {
  source = "controlshift/controlshift-redshift-sync/aws"

  aws_region = var.aws_region                                             // Default: "us-east-1"
  controlshift_environment = var.controlshift_environment                 // Default: "production"
  controlshift_hostname = var.controlshift_hostname                       // Default: "staging.controlshiftlabs.com"
  controlshift_organization_slug = var.controlshift_organization_slug
  failed_manifest_prefix = var.failed_manifest_prefix                     // Default: "failed"
  failure_topic_name = var.failure_topic_name                             // Default: "ControlshiftLambdaLoaderFailure"
  glue_scripts_bucket_name = var.glue_scripts_bucket_name
  manifest_bucket_name = var.manifest_bucket_name
  manifest_prefix = var.manifest_prefix                                   // Default: "manifests"
  receiver_timeout = var.receiver_timeout                                 // Default: 60
  redshift_cluster_identifier = var.redshift_cluster_identifier
  redshift_database_name = var.redshift_database_name
  redshift_password = var.redshift_password
  redshift_schema = var.redshift_schema                                   // Default: "public"
  redshift_security_group_id = var.redshift_security_group_id
  redshift_subnet_id = var.redshift_subnet_id
  redshift_username = var.redshift_username
  success_topic_name = var.success_topic_name                             // Default: "ControlshiftLambdaLoaderSuccess"
}
