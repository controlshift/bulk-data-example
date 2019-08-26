resource "aws_redshift_cluster" "default" {
  cluster_identifier = "redshift-cluster"
  database_name      = "agra_replica"
  master_username    = var.redshift_username
  master_password    = var.redshift_password
  node_type          = "dc2.large"
  cluster_type       = "single-node"
}

