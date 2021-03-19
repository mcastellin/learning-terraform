#!/bin/bash

export state_bucket=terraformstate78977

export TF_VAR_dns_name="$(aws route53 list-hosted-zones | jq --raw-output '.HostedZones[0].Name')"
echo "Identified default DNS_Name as [${TF_VAR_dns_name}]"

if [[ $(aws s3api list-buckets --query 'Buckets[].Name' | grep ${state_bucket}) ]]; then
    echo "Bucket ${state_bucket} already created."; 
else
    echo "Creating new s3 bucket with name ${state_bucket}"
    aws s3api create-bucket --bucket ${state_bucket} | jq
fi

echo "done."
