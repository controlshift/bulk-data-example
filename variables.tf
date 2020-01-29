variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "The AWS Region to use. All resources will be created in this region."
}

variable "controlshift_environment" {
  default = "staging"
  type        = string
  description = "The environment of your ControlShift instance. Either staging or production"
}

variable "controlshift_hostname" {
  default = "staging.controlshiftlabs.com"
  type        = string
  description = "The hostname of your ControlShift instance. Likely to be something like action.myorganization.org"
}

variable "controlshift_organization_slug" {
  type = string
  description = "The organization's slug in ControlShift platform. Ask support team (support@controlshiftlabs.com) to find this value."
}

variable "failed_manifest_prefix" {
  default = "failed"
  type        = string
  description = "A file prefix that will be used for manifest logs on failure"
}

variable "failure_topic_name" {
  default = "ControlshiftLambdaLoaderFailure"
  type        = string
  description = "An SNS topic name that will be notified about batch processing failures"
}

variable "failure_topic_name_for_run_glue_job_lambda" {
  default = "ControlshiftGlueJobFailure"
  type        = string
  description = "An SNS topic name that will be notified about batch processing failures"
}

variable "glue_scripts_bucket_name" {
  type        = string
  description = "Your S3 bucket name to store Glue scripts in"
}

variable "manifest_bucket_name" {
  type        = string
  description = "Your S3 bucket name to store manifests of ingests processed in"
}

variable "manifest_prefix" {
  default = "manifests"
  type        = string
  description = "A file prefix that will be used for manifest logs on success"
}

variable "public_subnet_cidr_block" {
  type = string
  default = "172.31.255.0/28"
  description = "CIDR block for the subnet with Internet access."
}

variable "receiver_timeout" {
  default = 60
  type        = number
  description = "The timeout for the receiving Lambda, in seconds"
}

variable "redshift_password" {
  type  = string
}

variable "redshift_schema" {
  type  = string
  default = "public"
  description = "The Redshift schema to load tables into"
}

variable "redshift_subnet_cidr_block" {
  type = string
  description = "CIDR block for subnet associated with new Redshift cluster"
  default = "172.31.48.0/20"
}

variable "redshift_username" {
  type = string
}

variable "success_topic_name" {
  default = "ControlshiftLambdaLoaderSuccess"
  type        = string
  description = "An SNS topic name that will be notified about batch processing successes"
}

variable "success_topic_name_for_run_glue_job_lambda" {
  default = "ControlshiftGlueJobSuccess"
  type        = string
  description = "An SNS topic name that will be notified about batch processing successes"
}
