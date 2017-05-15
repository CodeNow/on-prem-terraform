#!/usr/bin/env bash

REGION=$(terraform output -json | jq --raw-output '.aws_region.value')
ENV=$(terraform output -json | jq --raw-output '.environment.value')
VPC_ID=$(terraform output -json | jq --raw-output '.vpc_id.value')
BUCKET_NAME=$(terraform output -json | jq --raw-output '.kops_config_bucket.value')
CLUSTER_NAME=$(terraform output -json | jq --raw-output '.cluster_name.value')
SSH_PUBLIC_KEY_PATH=$(terraform output -json | jq --raw-output '.ssh_public_key_path.value')

kops create cluster \
  --zones="${REGION}a" \
  --name=${CLUSTER_NAME} \
  --vpc=${VPC_ID} \
  --cloud=aws \
  --cloud-labels="Environment=${ENV}" \
  --ssh-public-key=${SSH_PUBLIC_KEY_PATH} \
  --state=s3://${BUCKET_NAME} \
  --node-size=m4.large \
  --master-size=m4.large \
  --out=./step-2-kops --target=terraform

# Move file in order for it to be a valid module
mv ./step-2-kops/kubernetes.tf ./step-2-kops/main.tf
