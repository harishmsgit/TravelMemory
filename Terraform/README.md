Terraform Part 1 - Infrastructure for TravelMemory

Usage:

1. Install Terraform (>= 1.0) and configure AWS CLI with credentials.

2. Provide variables (either via `terraform.tfvars` or `-var` flags). Required variables:
   - `key_name` : existing EC2 Key Pair name
   - `admin_cidr` : your public IP/CIDR (e.g. `203.0.113.4/32`)

Example `terraform.tfvars`:

```
key_name = "my-keypair"
admin_cidr = "1.2.3.4/32"
aws_region = "us-east-1"
```

Commands:

```bash
cd terraform
terraform init
terraform plan -out plan.tfplan
terraform apply "plan.tfplan"
```

Notes:
- This scaffold creates a single public and a single private subnet in one AZ for simplicity.
- The EC2 instances have an IAM instance profile with `AmazonSSMManagedInstanceCore` so you can use Session Manager instead of exposing SSH.
- After `apply`, note the `web_public_ip` output to access the web server.

Additional setup:
- Use `terraform.tfvars.example` as a template for required variables.
- After infrastructure provisioning, run the Ansible deployment from the repository root with `ansible/site.yml` to configure the web and database servers.
