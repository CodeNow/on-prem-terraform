# Runnable On-Prem Terraform

### Dependencies

```
brew install terraform kops jq
```

### Setup

```
# TODO: Define permisisons
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```

Populate `environments/main.tfvars` with correct variables.

### Step 1

```
terraform init
# Bug in terraform requires explicitely requiring submodules https://github.com/hashicorp/terraform/issues/5190
terraform apply -target=module.step_1.module.key_pair -target=module.step_1.module.vpc -target=module.step_1.module.route53 -target=module.step_1.module.s3 -var-file="environments/main.tfvars"
```
Update DNS

### Step 2

```
soucre create-k8-cluster-terraform.bash environments/main.tfvars
```

### Step 3

```
terraform plan -var-file="environments/production.tfvars"
terraform apply -var-file="environments/production.tfvars"
```
