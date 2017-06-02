#!/usr/bin/env bash

# We need to run a refresh before we can run `terraform output`
terraform refresh -var-file=$1 > /dev/null

JSON=$(terraform output -json)
REGION=$(echo $JSON | jq --raw-output '.aws_region.value')
ENV=$(echo $JSON | jq --raw-output '.environment.value')
VPC_ID=$(echo $JSON | jq --raw-output '.vpc_id.value')
BUCKET_NAME=$(echo $JSON | jq --raw-output '.kops_config_bucket.value')
CLUSTER_NAME=$(echo $JSON | jq --raw-output '.cluster_name.value')
SSH_PUBLIC_KEY_PATH=$(echo $JSON | jq --raw-output '.ssh_public_key_path.value')

echo "Creating cluster in VPC $VPC_ID with name $CLUSTER_NAME"

kops create cluster \
  --zones="${REGION}a" \
  --name=${CLUSTER_NAME} \
  --vpc=${VPC_ID} \
  --node-count=4
  --cloud=aws \
  --cloud-labels="Environment=${ENV}" \
  --ssh-public-key=${SSH_PUBLIC_KEY_PATH} \
  --state=s3://${BUCKET_NAME} \
  --node-size=m4.large \
  --master-size=m4.large \
  --out=./step-2-kops --target=terraform

# Move file in order for it to be a valid module
mv ./step-2-kops/kubernetes.tf ./step-2-kops/main.tf
