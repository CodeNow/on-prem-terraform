# Runnable On-Prem Terraform

### Dependencies

```
brew install terraform kops jq kubectl
```

### Step 1: Obtaining AWS Access Tokens

```
# TODO: Define permisisons
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```

### Step 2: Populating Variables

Populate `environments/main.tfvars` with correct variables.

The following are the only required variables:

```
# Domain to be used by Runnable.
# Access to setting DNS nameservers is required.
# Multiple subdomains must be set for this domain
domain                     = "runnable.com"
# A Github organization id (See below of obtainig ID)
github_org_id              = "2828361" # Github ID for organization
# Location of previously generationg configuation
# Should be generated using github.com/CodeNow/on-prem-devops-scripts
lc_user_data_file_location = "~/dock-runnable-on-prem.sh" # File must be already generated
# Path to a publick key (See below of generating public key)
public_key_path            = "~/.ssh/*.pub" # A public key
```

##### Obtaining A Github ID

```
curl -sS "https://api.github.com/orgs/$ORGNAME" | jq '.id'
```

##### Obtaining A Public Key From Private Key

```
ssh-keygen -y -f ~/.ssh/${NAME}.pem >> ~/.ssh/${NAME}.pem.pub
```

### Step 3: Init Terraform and Apply First Part

```
terraform init
# Bug in terraform requires explicitely requiring submodules https://github.com/hashicorp/terraform/issues/5190
terraform apply -target=module.step_1.module.key_pair -target=module.step_1.module.vpc -target=module.step_1.module.route53 -target=module.step_1.module.s3 -var-file="environments/main.tfvars"
```

### Step 4: Update DNS

Run  `terraform referesh -var-file="environments/main.tfvars"` and update the name servers for your domain. There should 4 entries. DNS nameservers need to be propagated before going on to the next step.

### Step 5: Create Kops configuration

[kops]() is a tool to automatically spin up

```
source create-k8-cluster.bash environments/main.tfvars
```

### Step 6: Apply configuration

Finally, it's time to create the infrastructure. This include the kuberentes cluster, the auto scaling group for the dock workers, and the RDS database.

If you with to review the resources to be created, first run `terraform plan -var-file="environments/main.tfvars"`.

When you're ready to apply changes, just run

```
terraform apply -var-file="environments/main.tfvars"
```


### Step 7: Confirm Cluster is Up

After finishing the setup, you can now test if the cluster is up by running the following command.

```
kubectl get nodes
```

You should see something like this. It will take some time for nodes to appear as "Ready":

```
$ kubectl get nodes
NAME                                         STATUS         AGE       VERSION
ip-10-10-34-129.us-west-2.compute.internal   Ready,master   1h        v1.5.7
ip-10-10-57-73.us-west-2.compute.internal    Ready          1h        v1.5.7
ip-10-10-61-76.us-west-2.compute.internal    Ready          1h        v1.5.7
```

### Step 8: Add dashboard

After cluster is ready, run the following command to run the dashboard:

```
kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.5.0.yaml
```

Then, run `kubectl proxy` and go to [`127.0.0.1:8001/ui/`](http://127.0.0.1:8001/ui) to test it.
