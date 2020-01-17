variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "The AWS Region to use. All resources will be created in this region."
}
variable "redshift_password" {
  type        = string
}
variable "redshift_username" {
  type        = string
}
variable "receiver_bucket_name" {
  type        = string
  description = "Your S3 bucket name ingest CSVs will be stored in"
}
variable "manifest_bucket_name" {
  type        = string
  description = "Your S3 bucket name to store manifests of ingests processed in"
}
variable "glue_scripts_bucket_name" {
  type        = string
  description = "Your S3 bucket name to store AWS Glue job scripts in in"
}
variable "manifest_prefix" {
  default = "manifests"
  type        = string
  description = "A file prefix that will be used for manifest logs on success"
}
variable "failed_manifest_prefix" {
  default = "failed"
  type        = string
  description = "A file prefix that will be used for manifest logs on failure"
}

variable "controlshift_hostname" {
  default = "staging.controlshiftlabs.com"
  type        = string
  description = "The hostname of your ControlShift instance. Likely to be something like action.myorganization.org"
}

variable "controlshift_environment" {
}
