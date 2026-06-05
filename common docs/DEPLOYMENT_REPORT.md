# TravelMemory AWS Deployment Report

## Overview

This project deploys the TravelMemory MERN stack on AWS using Terraform for infrastructure provisioning and Ansible for configuration management.

- Terraform creates:
  - VPC with one public and one private subnet
  - Internet Gateway and NAT Gateway
  - Public and private route tables
  - A public EC2 instance for the web server
  - A private EC2 instance for the MongoDB database
  - Security groups for web and database traffic
  - IAM instance profile for EC2 with `AmazonSSMManagedInstanceCore`

- Ansible configures:
  - The web server with Node.js, Git, and nginx
  - The database server with MongoDB and secure access
  - The TravelMemory application repository, frontend build, and backend service

## Infrastructure Components

### VPC and Networking

- Public subnet hosts the web server and the NAT Gateway.
- Private subnet hosts the MongoDB database server.
- Public route table sends traffic to the Internet Gateway.
- Private route table sends outbound traffic through the NAT Gateway.

### EC2 and Security

- Web server security group allows:
  - HTTP (80) and HTTPS (443) from anywhere
  - SSH (22) from a configured admin CIDR only
- Database security group allows:
  - MongoDB (27017) only from the web server security group
- EC2 instances run under an IAM instance profile with AWS Systems Manager access.

## Application Architecture

- The web server hosts both the React frontend and the Express backend.
- nginx serves the built frontend from `/usr/share/nginx/html` and proxies API requests to the backend on port `3001`.
- The frontend is built with `REACT_APP_BACKEND_URL=http://<WEB_PUBLIC_IP>` so client requests reach nginx and then are proxied to the backend.
- The backend connects to MongoDB on the private database server using a secure private IP address.

## Deployment Process

### Terraform

1. Configure AWS CLI authentication.
2. Create `Terraform/terraform.tfvars` with at least:

```hcl
aws_region = "ap-south-1"
key_name = "<your-ec2-keypair>"
admin_cidr = "<your-public-ip>/32"
```

3. Run:

```bash
cd Terraform
terraform init
terraform plan -out plan.tfplan
terraform apply "plan.tfplan"
```

4. Note the `web_public_ip` output and the private IP for the database server.

### Ansible

1. Update `ansible/inventory.ini` with the EC2 addresses and SSH key path.
2. Set the correct Git repo URL and secure passwords in `ansible/vars.yml`.
3. Run:

```bash
cd ansible
ansible-playbook site.yml
```

## Security Hardening

- The database instance is isolated in a private subnet and does not receive a public IP.
- MongoDB accepts connections only from the web server security group.
- SSH is restricted to the admin CIDR from the internet.
- The web server uses a deployed service unit for the Node.js backend rather than running manually.
- IAM role on EC2 reduces the need for embedded AWS credentials.

## Notes

- This repository includes Terraform scripts in `Terraform/` and Ansible deployment files in `ansible/`.
- Screenshots or video recording are not included in this repository, but testing can be validated by visiting the public web server IP after deployment.
