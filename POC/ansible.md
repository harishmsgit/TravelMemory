# Ansible Deployment and Production Guidance

This document describes the TravelMemory Ansible deployment automation, responsibilities, and production-grade guidance.

## What it is

Ansible automates server configuration and application deployment.

Key files:
- `ansible/inventory.ini` — host inventory.
- `ansible/vars.yml` — deployment variables.
- `ansible/site.yml` — main orchestration playbook.
- `ansible/db.yml` — MongoDB installation and configuration.
- `ansible/web.yml` — web server setup, application deployment, nginx, and backend service.

## Responsibilities

- Install system packages and runtime dependencies.
- Deploy application code from the repository.
- Build the React frontend and serve it with nginx.
- Deploy the backend process with systemd.
- Configure MongoDB and database users.

## Production-grade guidance

- Use inventory files to separate dev, staging, and prod hosts.
- Keep secrets out of version control and use Ansible Vault.
- Ensure playbooks remain idempotent.
- Validate host connectivity before deployment.
- Use proper host groups such as `web` and `db` instead of `localhost` for remote targets.

## Why Ansible

- Ansible provides reliable automation and consistency.
- Playbooks document deployment flows and configuration expectations.
- It enables repeatable provisioning across environments.
- It is agentless and works well with SSH-managed EC2 hosts.

## Alternative deployment approaches

If you do not want to use Ansible, other clear options include:

- Shell / Bash scripts
  - Simple for small projects and quick one-off deployments.
  - Best for straightforward install/start workflows, but harder to maintain at scale.
- Docker and Docker Compose
  - Package frontend, backend, and database in containers.
  - Provides local parity and portable deployments across hosts.
- Terraform with startup scripts
  - Use Terraform for infrastructure provisioning and shell scripts or remote-exec for application deployment.
  - Good for separating infrastructure from application configuration.
- CI/CD pipelines
  - Automate build, test, and deploy with GitHub Actions, GitLab CI, Jenkins, or similar.
  - Useful when you want repeatable, versioned deployment flows triggered by code changes.
- Kubernetes / Helm
  - Best when you need scalable, containerized workloads and orchestration.
  - More complex, but strong for cluster-based production deployments.
- Platform services (PaaS)
  - AWS Elastic Beanstalk, Azure App Service, or similar.
  - Reduces server management and simplifies application hosting.

## Notes for improvement

- Remove hard-coded secrets from `ansible/vars.yml`.
- Use Ansible Vault for passwords and connection strings.
- Split environment-specific differences into separate inventories or roles.
