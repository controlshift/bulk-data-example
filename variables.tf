variable "aws_region" {}
variable "redshift_password" {}
variable "redshift_username" {}
variable "receiver_bucket_name" {}
variable "manifest_bucket_name" {}
variable "manifest_prefix" {
  default = "manifests/"
}
variable "failed_manifest_prefix" {
  default = "failed/"
}
variable "lambdas_bucket_name" {}
variable "controlshift_hostname" {
  default = "staging.controlshiftlabs.com"
}
