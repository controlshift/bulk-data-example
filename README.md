## Bulk Data API Redshift Pipeline Example
An example of using our [Terraform](https://www.terraform.io/) module for implementing a data ETL pipeline from [ControlShift](https://www.controlshiftlabs.com) to [Amazon Redshift.](https://aws.amazon.com/redshift/)

The output of this plan is a replica of all of the tables that underlie your ControlShift instance in a new Redshift instance which allows
for querying via SQL or other analysis.

If you are already using Terraform or Redshift it is probably best to either fork this example or [use the module we provide directly in your own plan](https://registry.terraform.io/modules/controlshift/controlshift-redshift-sync/aws/).

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

### Getting Started: How To Use This Example

If you are starting from scratch, these steps should get you a Redshift instance with data flowing into it.

#### Step 1: Get your permissions set up

First, we're going to make sure you have the right permissions set up to use with Terraform. These instructions assume you're using `aws-vault`.

1. Locate the AWS account you'll be using. (This might be your main account, or it might be another account within your organization.)
2. Find or create an IAM role in the account that has broad permissions. If you just created a new account in your organization, this role might already exist as "OrganizationAccountAccessRole".
3. Make sure your AWS IAM user has permission to assume that role. This may require e.g. attaching a specific policy to your IAM user or group that allows assuming that role.
4. Open your `$HOME/.aws/config` file and add a profile that uses that role. Make sure it's configured to use MFA as well. For the purposes of this example, we'll assume your new aws-vault profile is named `bulk-data`.

Once this is done, you should be able to run `aws-vault exec bulk-data -- echo "success"` without getting an error.

#### Step 2: Create a terraform.tfvars file

This Terraform config has several input variables that you'll need to define based on your organization and AWS account. Make a copy of `terraform.tfvars.example`, named `terraform.tfvars`, and replace the placeholders with your settings.

Here's a guide to what the variables do:

Name | Description
------------ | -------------
`aws_region` | The AWS Region to use. Should match the location of your Redshift instance, defaults to `us-east-1`.
`controlshift_environment` | The environment of your ControlShift instance. Either staging or production.
`controlshift_hostname` | The hostname of your ControlShift instance. Likely to be something like action.myorganization.org.
`controlshift_organization_slug` | The organization's slug in ControlShift platform. Ask support team (support@controlshiftlabs.com) to find this value.
`failed_manifest_prefix` | A file prefix that will be used for manifest logs on failure, defaults to `failed`.
`failure_topic_name` | An SNS topic name that will be notified about batch processing failures, defaults to `ControlshiftLambdaLoaderFailure`.
`failure_topic_name_for_run_glue_job_lambda` | An SNS topic name that will be notified about batch processing failures, defaults to `ControlshiftLambdaLoaderFailure`.
`glue_scripts_bucket_name` | Your S3 bucket name to store Glue scripts in.
`manifest_bucket_name` | Your S3 bucket name to store manifests of ingests processed in. Terraform will create this bucket for you. Must be globally unique.
`manifest_prefix` | A file prefix that will be used for manifest logs on success, defaults to `manifests`.
`receiver_timeout` | The timeout for the receiving Lambda, in seconds, defaults to `60`.
`redshift_password` | Redshift Password to use for database loads.
`redshift_schema` | The Redshift schema to load tables into, defaults to `public`.
`redshift_username` | Redshift Username to use for database loads.
`success_topic_name` | An SNS topic name that will be notified about batch processing successes, defaults to `ControlshiftLambdaLoaderSuccess`.
`success_topic_name_for_run_glue_job_lambda` | An SNS topic name that will be notified about batch processing successes, defaults to `ControlshiftGlueJobSuccess`.

#### Step 3: Run Terraform

It's time to use Terraform to create all the AWS resources! This is where the magic happens.

First, tell Terraform to set itself up:

```bash
terraform init
```

Then, run a Terraform apply:

```bash
aws-vault exec bulk-data -- terraform apply
```

This will show you a huge diff and ask your permission to proceed. Type "yes" and wait while Terraform creates all the resources.

When it's done, Terraform will output a Webhook URL. Hang on to this, because we're going to need it in a minute.

#### Step 4: Set up Tables in Redshift

For the ingest process to work correctly, tables that match the output of the ControlShift Bulk Data API must be set up
in Redshift first. We've provided a `create_tables.rb` script that will use the [ControlShift
Bulk Data Schema API](https://developers.controlshiftlabs.com/#bulk-data-schema) to generate `CREATE TABLE` DDL statements
that you'll need to run to populate the tables for ingest.

1. First generate the DDL statements:
```bash
./create_tables.rb > tables.sql
```

2. Log in to the AWS web console and navigate to Redshift. Open the Redshift query editor for `redshift-cluster`, and connect to the `agra_replica` database using your `redshift_username` and `redshift_password`.

3. Copy the contents of `tables.sql` into the editor and click the Run button. Once it's finished, you should be able to expand redshift-cluster > agra_replica > public > Tables and see a bunch of tables have been created.

#### Step 5: Tell ControlShift to send data to your webhook URL

We're almost there! It's time to tell ControlShift to send some bulk data over.

1. Log in to ControlShift and go to Settings > Integrations > Webhooks.
2. Make sure the "Do nightly CSV exports" and "Do incremental CSV exports" checkboxes are checked, and click the Save button.
3. Create a new webhook endpoint with the URL from the end of Step 3. Be sure to open the "Advanced settings" and paste in your AWS Account ID.
4. Contact support@controlshiftlabs.com and ask for the S3 permissions to be set up so Glue will be able to pull data from S3 buckets.

Once this is done, you can use the "Test Ingest" button to send over a full set of tables. This is the same export that should automatically happen nightly when "Do nightly CSV exports" is checked.


### Logs and Debugging

The pipeline logs its activity several places that are useful for debugging.

- In CloudWatch Logs of Lambda, Glue Job and Crawler, and S3 activity.
- In DynamoDB tables for each manifest.
- In Redshift, in the Loads tab of your datawarehouse instance.
- In each manifest load whose results stored in S3.
