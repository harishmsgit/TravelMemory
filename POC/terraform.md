# Terraform Infrastructure and Production Guidance

This document describes the TravelMemory Terraform infrastructure, intended topology, and production-grade recommendations.

## What it is

Terraform is a declarative Infrastructure as Code tool that provisions cloud resources from configuration files. In this project, Terraform creates the AWS network, compute instances, security boundaries, and IAM settings needed to deploy TravelMemory.

The `Terraform/` directory contains the resource definitions and configuration values. When you run `terraform init`, `terraform plan`, and `terraform apply`, Terraform reads these files and creates or updates AWS resources to match the declared state.

Key files and what they do:
- `Terraform/provider.tf`
  - Defines the AWS provider and region.
  - Configures the AWS API access method used by Terraform.
- `Terraform/vpc.tf`
  - Declares the VPC, subnets, route tables, and internet/NAT gateways.
  - Sets up the network topology for public web traffic and private database traffic.
- `Terraform/ec2.tf`
  - Creates EC2 instances for the web server and the database server.
  - Defines the instance type, AMI, key pair, user data, and networking associations.
- `Terraform/security.tf`
  - Defines security groups used to control inbound/outbound access.
  - Enforces rules such as allowing HTTP/HTTPS to the web tier and restricting DB access to the web tier only.
- `Terraform/iam.tf`
  - Declares IAM roles, instance profiles, and permissions required by EC2 instances.
  - Ensures instances can access AWS services safely if needed.
- `Terraform/outputs.tf`
  - Exports values from the applied infrastructure.
  - Makes outputs like public IPs and private IPs available after deployment.
- `Terraform/variables.tf`
  - Declares configurable variables and default values.
  - Centralizes deployment settings such as region, key name, and CIDR ranges.

## Responsibilities

- Create an isolated VPC for the application.
- Deploy a public web server and a private database server.
- Enforce tier separation between web and data layers.
- Provide repeatable, version-controlled infrastructure provisioning.

## Production-grade guidance

- Use Terraform for infrastructure provisioning and version control.
- Store variables securely in `terraform.tfvars` or a protected backend.
- Apply changes through an automated pipeline.
- Keep Terraform state secure and use remote state storage.
- Adopt a multi-AZ design for production availability.
- Avoid single points of failure for critical services.

## Why Terraform

- Infrastructure as Code makes provisioning repeatable and auditable.
- Terraform supports AWS resources and lifecycle management.
- It enables consistent staging and production environments.
- It allows infrastructure changes to be reviewed in source control.

## Terraform lifecycle

Terraform manages infrastructure in a predictable lifecycle:

- `terraform init`
  - Initializes the working directory.
  - Downloads provider plugins and installs required modules.
  - Sets up the backend for state if configured.
- `terraform plan`
  - Compares the current Terraform configuration to the existing deployed resources.
  - Generates a preview of proposed changes without applying them.
  - Helps catch unexpected changes before deployment.
- `terraform apply`
  - Applies the planned infrastructure changes to AWS.
  - Creates, updates, or destroys resources to match the declared state.
  - Records the resulting infrastructure state in the Terraform state file.
- `terraform destroy`
  - Removes all resources managed by the configuration.
  - Useful for teardown in development or temporary environments.

### Terraform state

- Terraform tracks infrastructure using a state file, typically `terraform.tfstate`.
- The state file represents the current deployed resource inventory.
- Keep state secure and use remote state (S3, Terraform Cloud) for team collaboration.
- Avoid editing state files manually unless you understand the consequences.

## Notes for improvement

- Extend the VPC to multiple availability zones for resiliency.
- Add load balancing and autoscaling for the web tier.
- Consider managed database services like MongoDB Atlas or Amazon DocumentDB.
- Add compliance validation for networking and security group rules.
