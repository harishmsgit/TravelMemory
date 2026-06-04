Terraform Part 1 - Infrastructure for TravelMemory

Usage:

1. Install Terraform (>= 1.0) and configure AWS CLI with credentials.

2. Provide variables (either via `terraform.tfvars` or `-var` flags). Required variables:
   - `key_name` : existing EC2 Key Pair name in the target AWS region
   - `admin_cidr` : your public IP/CIDR (e.g. `203.0.113.4/32`)
   - `aws_region` : AWS region to deploy into (must match the region where the key pair exists)

Example `terraform.tfvars`:

```
key_name = "my-keypair"
admin_cidr = "1.2.3.4/32"
aws_region = "us-east-1"
```

Commands:

```bash
cd Terraform
terraform init
terraform plan -out plan.tfplan \
  -var "aws_region=ap-south-1" \
  -var "key_name=capstone-project-KP" \
  -var "admin_cidr=13.127.59.251/32"
terraform apply "plan.tfplan"
```

Note: the `key_name` value is the EC2 key pair name stored in AWS, not the local `.pem` filename.

Notes:
- This scaffold creates a single public and a single private subnet in one AZ for simplicity.
- The EC2 instances have an IAM instance profile with `AmazonSSMManagedInstanceCore` so you can use Session Manager instead of exposing SSH.
- After `apply`, note the `web_public_ip` output to access the web server.

Additional setup:
- Use `terraform.tfvars.example` as a template for required variables.
- After infrastructure provisioning, run the Ansible deployment from the repository root with `ansible/site.yml` to configure the web and database servers.
