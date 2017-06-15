# Runnable On-Prem Terraform

```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
terraform get
terraform plan
terraform apply
```

### Setting up Terraform

```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
cp terraform.tfstate terraform.tfstate.bak # If there is a state file already
aws s3api create-bucket --bucket $BUCKET_NAME --region us-west-2 --create-bucket-configuration LocationConstraint=us-west-2
aws s3api put-bucket-versioning --bucket $BUCKET_NAME  --versioning-configuration Status=Enabled
# Input "yes" for both questions ('Import from S3', 'Import from local state')
terraform init -backend-config="bucket=$BUCKET_NAME" -backend-config="key=/$ENVIRONMENT" -backend-config="region=us-west-2" -backend=true
```
