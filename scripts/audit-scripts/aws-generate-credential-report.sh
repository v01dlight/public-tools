#!/bin/sh
# This script is for auditing AWS users and their credentials. It requires the AWS CLI to already be set up and authenticated, 
# as well as for you to have the relevant AWS permissions to generate credential reports.

today=$(date "+%Y-%m-%d")

# generate a fresh credential report
aws iam generate-credential-report &&

# pull the credential report and write it to a CSV file
aws iam get-credential-report | base64 --decode > aws-credential-report_"${today}".csv
