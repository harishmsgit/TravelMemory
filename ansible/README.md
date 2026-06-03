# Ansible Deployment for TravelMemory

This folder contains Ansible configuration and playbooks for deploying the TravelMemory MERN stack to AWS EC2 instances.

## Files

- `ansible.cfg` - Ansible configuration defaults.
- `inventory.ini` - Example inventory for the public web server and private database server.
- `vars.yml` - Deployment variables, including repository URL, MongoDB credentials, and directory paths.
- `site.yml` - Main playbook that imports `db.yml` and `web.yml`.
- `db.yml` - Playbook to install and configure MongoDB on the private database server.
- `web.yml` - Playbook to install Node.js, clone the app repo, build the React frontend, and configure nginx + backend service.

## Usage

1. Update `inventory.ini` with the EC2 public and private IP addresses and the SSH private key path.
2. Update `vars.yml` with your actual Git repository URL and secure passwords.
3. Run the playbooks from the `ansible` directory:

```bash
cd ansible
ansible-playbook site.yml
```

## Notes

- The `db` host is expected to be reachable through the `web` host as a proxy because it resides in a private subnet.
- The web server uses nginx to serve the frontend and proxy `/trip` and `/hello` requests to the backend service on port `3001`.
