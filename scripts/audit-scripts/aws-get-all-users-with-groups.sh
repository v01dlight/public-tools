#!/bin/sh
# This script is for auditing AWS users and their group memberships. It requires the AWS CLI to already be set up and authenticated, 
# as well as for you to have the relevant AWS permissions to view groups for other users. It also requires jq for parsing JSON.

for u_name in $(aws iam list-users --output json | jq -r '.Users[].UserName') ; do
  groups="$(aws iam list-groups-for-user \
    --user-name "${u_name}" \
    | cut -w -f 5 \
    | tr '\n' ' ')"
  echo "${u_name}, ${groups}" >> aws_users_with_groups.csv
done
