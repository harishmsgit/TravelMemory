# Requirement Setup

## Part 1: Infrastructure Setup with Terraform

1. AWS Setup and Terraform Initialization
   - Configure AWS CLI with valid AWS credentials.
   - Authenticate the CLI against the target AWS account.
   - Initialize Terraform in the project directory with `terraform init`.
   - Confirm the AWS provider is configured correctly.

2. VPC and Network Configuration
   - Create a VPC for the TravelMemory application.
   - Create one public subnet and one private subnet.
   - Create an Internet Gateway and attach it to the VPC.
   - Create a NAT Gateway for outbound internet access from the private subnet.
   - Create route tables for both public and private subnets.
   - Associate the public subnet with the public route table and the private subnet with the private route table.

3. EC2 Instance Provisioning
   - Provision one EC2 instance in the public subnet for the web server.
   - Provision one EC2 instance in the private subnet for the database server.
   - Ensure the web server instance is accessible via SSH from the users IP address only.
   - Ensure the database instance is not publicly accessible.

4. Security Groups and IAM Roles
   - Create a security group for the web server that allows HTTP/HTTPS and SSH from the allowed IP.
   - Create a security group for the database server that allows MongoDB access from the web server only.
   - Create an IAM role for the web server EC2 instance with required permissions.
   - Create an IAM role for the database server EC2 instance if needed for AWS access.

5. Resource Output
   - Output the public IP address of the web server EC2 instance.
   - Output any other relevant connection details needed to access the deployed application.

## Part 2: Configuration and Deployment with Ansible

1. Ansible Configuration
   - Configure Ansible inventory with the AWS EC2 hosts.
   - Ensure Ansible can connect to the EC2 instances via SSH.
   - Define separate host groups for `web` and `db`.

2. Web Server Setup
   - Install Node.js and npm on the web server via Ansible.
   - Clone the MERN application repository to the web server.
   - Install backend and frontend dependencies.
   - Build or start the React frontend as required.

3. Database Server Setup
   - Install MongoDB on the database server via Ansible.
   - Configure MongoDB for the TravelMemory database.
   - Create MongoDB users and grant appropriate roles.
   - Secure MongoDB by restricting access to the web server and disabling open connections.

4. Application Deployment
   - Configure necessary environment variables for backend and frontend.
   - Start the Node.js backend application.
   - Ensure the React frontend is configured to communicate with the backend service.
   - Verify the frontend and backend can exchange data successfully.

5. Security Hardening
   - Implement firewall rules on the AWS security groups.
   - Use SSH key pairs for EC2 access.
   - Disable password-based SSH login and root login if appropriate.
   - Apply any additional security measures needed for the deployment.

## Deliverables

- Terraform scripts for AWS infrastructure setup.
- Ansible playbooks for configuration and deployment of the MERN application.
- A detailed report documenting the implementation process and component interaction.
- Screenshots or a video recording demonstrating the working MERN application.
