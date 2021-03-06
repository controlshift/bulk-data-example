## Bulk Data API Redshift Pipeline Example
An example of using our [Terraform](https://www.terraform.io/) module for implementing a data ETL pipeline from [ControlShift](https://www.controlshiftlabs.com) to [Amazon Redshift.](https://aws.amazon.com/redshift/)

The output of this plan is a replica of all of the tables that underlie your ControlShift instance in a new Redshift instance which allows
for querying via SQL or other analysis.

If you are already using Terraform or Redshift it is probably best to either fork this example or [use the module we provide directly in your own plan](https://registry.terraform.io/modules/controlshift/controlshift-redshift-sync/aws/)

### Overview

The Terraform plan sets up resources in your AWS environment to process webhooks generated by the [ControlShift Bulk Data API.](https://developers.controlshiftlabs.com/#bulk-data)

The integration is based on the [aws-lambda-redshift-loader](https://github.com/awslabs/aws-lambda-redshift-loader) provided by
AWS but replaces the manual setup steps from their README with a Terraform plan. In addition the Terraform plan includes
resourced that are specific to accepting ControlShift Bulk Data API webhooks.

The resources created include:

- DynamoDB tables that store configuration information and logs each table load processed.
- Lambda functions that process incoming webhooks, store CSV files onto S3 and load those files into tables in Redshift.
- Glue connection, crawler and job for importing `signatures` full table export.
- S3 buckets for storing incoming S3 CSVs and manifests of load activity.
- S3 bucket for storing Glue resources and temporary files.
- A Web API Gateway to connect AWS Lambdas to the web.
- IAM permissions to make everything work securely.
- Network resources for allowing connection between Glue, S3 and Redshift.

### Prerequisites

- Familiarity with Amazon Web Services, Redshift, and Terraform
- Use of [aws-vault](https://github.com/99designs/aws-vault) or a similar tool for using AWS secrets securely.
- The `terraform` command line tool. [Download](https://www.terraform.io/downloads.html)

### Setup Tables in Redshift

For the ingest process to work correctly, tables that match the output of the ControlShift Bulk Data API must be setup
in Redshift first. We've provided a create_tables.rb script that will use the [ControlShift
Bulk Data Schema API](https://developers.controlshiftlabs.com/#bulk-data-schema) to generate `CREATE TABLE` DDL statements
that you'll need to run to populate the tables for ingest.

First generate the DDL statements, and then apply them manually in your Redshift environment.
```
create_tables.rb > tables.sql
```

### Terraform Variables

Terraform input variables are defined in variables.tf. You'll want to create your own `terraform.tfvars` file with the
correct values for your specific environment.

Name | Description
------------ | -------------
aws_region | The AWS Region to use. Should match the location of your Redshift instance, defaults to `us-east-1`.
controlshift_environment | The environment of your ControlShift instance. Either staging or production.
controlshift_hostname | The hostname of your ControlShift instance. Likely to be something like action.myorganization.org.
controlshift_organization_slug | The organization's slug in ControlShift platform. Ask support team (support@controlshiftlabs.com) to find this value.
failed_manifest_prefix | A file prefix that will be used for manifest logs on failure, defaults to `failed`.
failure_topic_name | An SNS topic name that will be notified about batch processing failures, defaults to `ControlshiftLambdaLoaderFailure`.
failure_topic_name_for_run_glue_job_lambda | An SNS topic name that will be notified about batch processing failures, defaults to `ControlshiftLambdaLoaderFailure`.
glue_scripts_bucket_name | Your S3 bucket name to store Glue scripts in.
manifest_bucket_name | Your S3 bucket name to store manifests of ingests processed in. Terraform will create this bucket for you. Must be globally unique.
manifest_prefix | A file prefix that will be used for manifest logs on success, defaults to `manifests`.
receiver_timeout | The timeout for the receiving Lambda, in seconds, defaults to `60`.
redshift_password | Redshift Password to use for database loads.
redshift_schema | The Redshift schema to load tables into, defaults to `public`.
redshift_username | Redshift Username to use for database loads.
success_topic_name | An SNS topic name that will be notified about batch processing successes, defaults to `ControlshiftLambdaLoaderSuccess`.
success_topic_name_for_run_glue_job_lambda | An SNS topic name that will be notified about batch processing successes, defaults to `ControlshiftGlueJobSuccess`.

### Run Terraform

You'll need:

- AWS Credentials with rather broad permissions in your environment.
- AWS restricts certain IAM operations this terraform plan uses to credentials that have been authenticated with MFA.
As a result using `aws-vault` or a similar tool to assume a role with the correct permissions, protected by MFA is probably necessary.

Check out a copy of this repository locally, and then in the project directory:

```bash
# download the terraform dependencies and initialize the directory
terraform init
# use aws-vault to generate temporary AWS session credentials using the bulk-data profile and then use them to apply the plan
aws-vault exec bulk-data -- terraform apply
```

The output of the terraform plan is a Webhook URL. You'll need to configure this in your instance of the ControlShift platform
via Settings > Integrations > Webhooks.

Once the webhook is configured it should populate the tables within your Redshift instance nightly. Alternatively, you can use
the "Test Ingest" feature to trigger a full-table refresh on demand from the ControlShift web UI.

### Logs and Debugging

The pipeline logs its activity several places that are useful for debugging.

- In CloudWatch Logs of Lambda, Glue Job and Crawler, and S3 activity.
- In DynamoDB tables for each manifest.
- In Redshift, in the Loads tab of your datawarehouse instance.
- In each manifest load whose results stored in S3.
