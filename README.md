# Runnable On-Prem Terraform

### Setup

```
# TODO: Define permisisons
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```

### Step 1

```
terraform get
terraform plan -target=step-1
terraform apply -target=step-1
```

### Step 2

```
soucre create-k8-cluster-terraform.bash
```

### Step 3

```
terraform plan
terraform apply
```
