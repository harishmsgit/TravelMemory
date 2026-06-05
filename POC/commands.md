# TravelMemory Command Guide

This document provides a comprehensive, step-by-step command reference for local development, infrastructure provisioning, deployment, and verification.

## 1. Prerequisites

### Local environment

- Node.js 18.x or 20.x LTS
- npm 10.x or compatible
- MongoDB Atlas or local MongoDB server
- Bash shell on Windows (Git Bash or WSL recommended)

### AWS deployment environment

- Terraform 1.x
- AWS CLI configured with credentials
- Ansible installed on the deployment machine
- Access to the EC2 key pair `.pem` file for SSH

## 2. Local development setup

### 2.1 Backend

```bash
cd backend
npm install
cp .env.example .env 2>/dev/null || true
```

Edit `backend/.env` with a local MongoDB URI if needed:

```bash
cat > backend/.env <<'EOF'
PORT=3001
MONGO_URI=mongodb://127.0.0.1:27017/travelmemory
EOF
```

Start the backend:

```bash
cd backend
node index.js
```

Verify the backend:

```bash
curl http://localhost:3001/hello
```

### 2.2 Frontend

```bash
cd frontend
npm install
cp .env.example .env 2>/dev/null || true
```

Edit `frontend/.env` if needed:

```bash
cat > frontend/.env <<'EOF'
REACT_APP_BACKEND_URL=http://localhost:3001
EOF
```

Start the frontend:

```bash
cd frontend
npm start
```

Open the app at `http://localhost:3000`.

### 2.3 Local MongoDB

#### Install MongoDB (Ubuntu)

```bash
sudo apt update
sudo apt install -y mongodb
```

#### Start MongoDB

```bash
sudo systemctl enable --now mongod
sudo systemctl start mongod
```

#### Stop MongoDB

```bash
sudo systemctl stop mongod
```

#### Restart MongoDB

```bash
sudo systemctl restart mongod
```

#### Check MongoDB service status

```bash
sudo systemctl status mongod
```

#### Confirm MongoDB is listening on port 27017

```bash
sudo ss -tulpn | grep 27017
sudo lsof -i :27017
```

#### View MongoDB logs

```bash
sudo journalctl -u mongod -n 50
sudo journalctl -u mongod -f
```

#### Connect with the Mongo shell

```bash
mongosh
```

#### Verify database and collection existence

```bash
mongosh --eval "show dbs"
mongosh --eval "use travelmemory; show collections"
```

#### Create backend `.env` for MongoDB

```bash
cd backend
cat > .env <<'EOF'
PORT=3001
MONGO_URI=mongodb://127.0.0.1:27017/travelmemory
EOF
```

#### Verify MongoDB connectivity from the backend

```bash
cd backend
npm run check-mongo
```

#### MongoDB Atlas connection example

If you use MongoDB Atlas instead of a local MongoDB instance, create `backend/.env` with your Atlas URI:

```bash
cd backend
cat > .env <<'EOF'
PORT=3001
MONGO_URI="mongodb+srv://<username>:<password>@<cluster>.mongodb.net/travelmemory?retryWrites=true&w=majority"
EOF
```

Then verify with:

```bash
npm run check-mongo
```

#### Atlas network access and user permissions

- In Atlas, add the server public IP or `0.0.0.0/0` to the Network Access list.
- Create a database user with `readWrite` role on the `travelmemory` database.
- Use the Atlas connection string from the cluster `Connect` dialog.

## 3. Optional local helper scripts

The repository includes helper scripts under `scripts/` for convenience, but they are not required. Use them only if you want a faster local startup path; otherwise, run the commands manually from the sections above.

### 3.1 Start backend with script

```bash
bash scripts/start_backend.sh
```

This optional helper:
- installs backend dependencies
- copies `.env.example` to `.env` if missing
- starts the backend with `node index.js`

### 3.2 Start frontend with script

```bash
bash scripts/start_frontend.sh
```

This optional helper:
- installs frontend dependencies
- copies `.env.example` to `.env` if missing
- starts the React development server

### 3.3 Install and run all locally

```bash
bash scripts/install_and_start_all.sh
```

This optional helper:
- cleans package caches
- installs MongoDB on Ubuntu
- starts `mongod`
- installs backend/frontend dependencies
- starts the backend and frontend in the background

> Note: The `.sh` files are retained for convenience. They do not need to be deleted, and they are intended to complement the single command guide rather than replace it.

## 4. Terraform infrastructure provisioning

### 4.1 Prepare Terraform variables

Create `Terraform/terraform.tfvars` or pass variables at the command line.

Example `Terraform/terraform.tfvars`:

```hcl
key_name = "travelMemory-KP"
admin_cidr = "13.233.183.20/32"
aws_region = "ap-south-1"
```

### 4.2 Initialize Terraform

```bash
cd Terraform
terraform init
```

### 4.3 Generate a plan

```bash
terraform plan -out plan.tfplan \
  -var "aws_region=ap-south-1" \
  -var "key_name=travelMemory-KP" \
  -var "admin_cidr=13.233.183.20/32"
```

### 4.4 Apply the plan

```bash
terraform apply "plan.tfplan"
```

Or directly:

```bash
terraform apply \
  -var "aws_region=ap-south-1" \
  -var "key_name=travelMemory-KP" \
  -var "admin_cidr=13.233.183.20/32"
```

### 4.5 Capture outputs

```bash
cd Terraform
terraform output -raw web_public_ip
terraform output -raw db_private_ip
terraform output -json > outputs.json
```

## 5. Ansible deployment

### 5.1 Update inventory

Edit `ansible/inventory.ini` with the EC2 web host and database host.

Example:

```ini
[webservers]
web1 ansible_host=13.233.183.20 ansible_user=ubuntu ansible_private_key_file=/path/to/travelMemory-KP.pem

[databases]
db1 ansible_host=172.31.43.42 ansible_user=ubuntu ansible_private_key_file=/path/to/travelMemory-KP.pem

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

> Note: `172.31.43.42` is the private database IP inside the VPC. It is only reachable from the web host or via an SSH bastion/proxy jump, not directly from the public internet.
>
> If you need to assess or connect to the private DB host from outside the VPC, use one of these secure methods:
> - SSH to the web host first, then SSH from there to the private DB host.
> - Use SSH ProxyJump from your laptop through the web host.
> - Create a secure VPN or AWS Session Manager tunnel into the VPC.
> - Do not expose the private DB IP directly to the public internet.

### 5.2 Update variables

Edit `ansible/vars.yml` with the proper repository URL, app directory, and MongoDB URI.

### 5.3 Test connectivity

```bash
cd ansible
ansible web1 -i inventory.ini -m ping
ansible db1 -i inventory.ini -m ping
```

### 5.4 Run the playbooks

From the repo root:

```bash
cd ansible
ansible-playbook site.yml -i inventory.ini -v
```

The Ansible playbooks will:
- install required packages
- clone the repository
- build the frontend
- create the backend service
- configure nginx and MongoDB

## 6. Verification commands

### 6.1 SSH into the web server

```bash
WEB_PUBLIC_IP=$(terraform output -raw web_public_ip)
ssh -i ~/.ssh/travelMemory-KP.pem ubuntu@$WEB_PUBLIC_IP
```

### 6.2 Check installed package versions

```bash
git --version
node -v
npm -v
sudo nginx -v
sudo systemctl status travelmemory-backend
```

### 6.3 Useful local troubleshooting commands

- Check backend port `3001`:
  ```bash
  sudo lsof -i :3001
  sudo ss -tulpn | grep 3001
  sudo netstat -tulpn | grep 3001
  ```
- Check frontend port `3000`:
  ```bash
  sudo lsof -i :3000
  sudo ss -tulpn | grep 3000
  sudo netstat -tulpn | grep 3000
  ```
- Check MongoDB port `27017`:
  ```bash
  sudo lsof -i :27017
  sudo ss -tulpn | grep 27017
  sudo netstat -tulpn | grep 27017
  ```
- List running Node processes:
  ```bash
  ps -ef | grep node
  pgrep -fl node
  ```
- Kill a process using a port:
  ```bash
  sudo fuser -n tcp 3001 -k
  sudo fuser -n tcp 3000 -k
  sudo fuser -n tcp 27017 -k
  ```
- Or kill by PID:
  ```bash
  sudo kill <PID>
  sudo kill -9 <PID>   # use only if needed
  ```
- Check service status for MongoDB and nginx:
  ```bash
  sudo systemctl status mongod
  sudo systemctl status nginx
  ```

### 6.4 Confirm deployed repo

```bash
ls -la /home/ubuntu/travelmemory
```

### 6.4 Build / verify frontend

```bash
cd /home/ubuntu/travelmemory/frontend
npm install
npm run build
ls -la build/
```

### 6.5 Validate backend environment

```bash
cat /home/ubuntu/travelmemory/backend/.env
```

### 6.6 Restart services

```bash
sudo systemctl daemon-reload
sudo systemctl restart travelmemory-backend
sudo systemctl restart nginx
sudo systemctl status travelmemory-backend
sudo systemctl status nginx
```

### 6.7 Verify backend health

```bash
curl http://localhost:3001/hello
```

### 6.8 Check logs

```bash
sudo journalctl -u travelmemory-backend -n 50
sudo journalctl -u travelmemory-backend -f
sudo tail -n 50 /var/log/nginx/error.log
sudo tail -n 50 /var/log/nginx/access.log
```

## 7. Application access

### 7.1 Browser access

```bash
WEB_PUBLIC_IP=$(terraform output -raw web_public_ip)
echo "http://$WEB_PUBLIC_IP"
```

Open the URL in a browser.

### 7.2 API smoke tests

```bash
curl http://$WEB_PUBLIC_IP/trip
curl http://$WEB_PUBLIC_IP/hello
```

### 7.3 Create a sample trip

```bash
curl -X POST http://$WEB_PUBLIC_IP/trip \
  -H "Content-Type: application/json" \
  -d '{
    "tripName": "POC Trip",
    "startDateOfJourney": "2026-06-01",
    "endDateOfJourney": "2026-06-05",
    "nameOfHotels": "Example Hotel",
    "placesVisited": "City A, City B",
    "totalCost": 1000,
    "tripType": "leisure",
    "experience": "Test experience",
    "image": "https://example.com/image.jpg",
    "shortDescription": "A sample travel memory.",
    "featured": true
  }'
```

## 8. Troubleshooting hints

### MongoDB connection failures

- Confirm the `MONGO_URI` is correct and URL-encoded.
- Confirm the Atlas network access list allows the web server IP.
- Verify the MongoDB app user has `readWrite` on the `travelmemory` database.

### Nginx or backend service failures

- Check `sudo systemctl status travelmemory-backend`
- Check `sudo journalctl -u travelmemory-backend -n 100`
- Check `sudo tail -n 50 /var/log/nginx/error.log`

### Terraform issues

- Re-run `terraform init` if provider plugins are missing.
- Delete stale plans and recreate with `terraform plan`.
- Ensure `key_name` exists in the selected AWS region.

## 9. Notes

- Keep environment variables and secrets out of source control.
- Use the command sequences above in order: provision infra, configure hosts, then verify.
- Use `terraform output` to retrieve values for the next deployment and verification steps.

