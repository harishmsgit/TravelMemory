# TravelMemory Deployment & Verification Commands

Complete sequential guide for provisioning infrastructure, configuring servers, and verifying the TravelMemory application.

---

## PHASE 1: Prerequisites & Environment Setup

### Step 1.1: Install Terraform (Linux/Mac/Windows)

**On Ubuntu/Linux:**
```bash
cd ~
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform -y
terraform --version
```

**On Windows:**
- Download from: https://www.terraform.io/downloads
- Or use package manager: `choco install terraform` (if Chocolatey is installed)

### Step 1.2: Install AWS CLI

**On Ubuntu/Linux:**
```bash
sudo apt install awscli -y
aws --version
```

**On Windows:**
- Download from: https://aws.amazon.com/cli/
- Or use: `choco install awscli`

### Step 1.3: Configure AWS Credentials

**Option A: Interactive Setup (Recommended)**
```bash
aws configure
# Prompted to enter:
# AWS Access Key ID: [your-access-key]
# AWS Secret Access Key: [your-secret-key]
# Default region name: ap-south-1
# Default output format: json
```

**Option B: Environment Variables (Quick)**
```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="ap-south-1"
```

**Verify Setup:**
```bash
aws sts get-caller-identity
# Should return your AWS Account ID and User ARN
```

**How to get AWS credentials:**
1. Go to AWS Console → IAM → Users → Select your user
2. Click **Security credentials** tab
3. Under **Access keys**, click **Create access key** (if none exist)
4. Copy the **Access Key ID** and **Secret Access Key**

---

## PHASE 2: Terraform Infrastructure Provisioning

### Step 2.1: Prepare Terraform Variables

Before running Terraform, gather the following:

1. **AWS Region** (should match where your key pair exists)
   - Default: `ap-south-1`
   - Ensure key pair exists in this region

2. **EC2 Key Pair Name** (without `.pem` extension)
   - Go to AWS Console → EC2 → Key Pairs
   - Note the name of an existing key pair (e.g., `travelMemory-KP`)
   - Ensure you have the `.pem` file locally for SSH access later

3. **Your Public IP (CIDR format)**
   - Windows PowerShell: `(Invoke-WebRequest -Uri "https://checkip.amazonaws.com").Content`
   - Linux/Mac: `curl https://checkip.amazonaws.com`
   - Example output: `203.0.113.45` → use as `203.0.113.45/32`

### Step 2.2: Initialize & Plan Terraform

**From the `Terraform/` directory:**
```bash
cd Terraform

# Initialize Terraform (download providers)
terraform init

# Generate plan with variables
terraform plan -out plan.tfplan \
  -var "aws_region=ap-south-1" \
  -var "key_name=travelMemory-KP" \
  -var "admin_cidr=13.23.1833.20/32"
```

**Expected Output:**
- Plan shows 2 EC2 instances, VPC, subnets, security groups
- No errors about missing key pairs

### Step 2.3: Apply Terraform Configuration

```bash
# Fresh apply (recommended if plan is stale)
terraform apply \
  -var "aws_region=ap-south-1" \
  -var "key_name=travelMemory-KP" \
  -var "admin_cidr=13.23.1833.20/32"

# OR apply existing plan
terraform apply "plan.tfplan"
```

**Type `yes` when prompted to confirm.**

### Step 2.4: Capture Terraform Outputs

After apply succeeds, capture the EC2 public/private IPs:

```bash
# Get web server public IP (needed for Ansible & app access)
WEB_PUBLIC_IP=$(terraform output -raw web_public_ip)
echo $WEB_PUBLIC_IP

# Get database server private IP (needed for Ansible inventory)
DB_PRIVATE_IP=$(terraform output -raw db_private_ip)
echo $DB_PRIVATE_IP

# Save for next phase
terraform output -json > outputs.json
cat outputs.json
```

### Step 2.5: Troubleshooting Terraform

**If "InvalidKeyPair.NotFound" error:**
```bash
# Verify key pair exists in the correct region
aws ec2 describe-key-pairs --key-names travelMemory-KP --region ap-south-1

# If not found, create it:
aws ec2 create-key-pair --key-name travelMemory-KP --region ap-south-1 \
  --query 'KeyMaterial' --output text > travelMemory-KP.pem
chmod 400 travelMemory-KP.pem
```

**If "Saved plan is stale" error:**
```bash
# Delete stale plan and recreate
rm plan.tfplan
terraform plan -out plan.tfplan \
  -var "aws_region=ap-south-1" \
  -var "key_name=travelMemory-KP" \
  -var "admin_cidr=13.127.59.251/32"
terraform apply "plan.tfplan"
```

---

## PHASE 3: Ansible Configuration

### Step 3.1: Install Ansible

**On Ubuntu/Linux:**
```bash
sudo apt update
sudo apt install ansible-core -y
ansible --version
```

**On Windows:**
- Use WSL (Windows Subsystem for Linux), then run Linux commands above
- Or use: `pip install ansible`

### Step 3.2: Update Ansible Inventory

**Edit `ansible/inventory.ini`:**
```ini
[webservers]
web1 ansible_host=<WEB_PUBLIC_IP> ansible_user=ubuntu ansible_private_key_file=/path/to/travelMemory-KP.pem

[databases]
db1 ansible_host=<DB_PRIVATE_IP> ansible_user=ubuntu ansible_private_key_file=/path/to/travelMemory-KP.pem

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

**Example:**
```ini
[webservers]
web1 ansible_host=52.66.213.14 ansible_user=ubuntu ansible_private_key_file=~/travelMemory-KP.pem

[databases]
db1 ansible_host=10.0.2.253 ansible_user=ubuntu ansible_private_key_file=~/travelMemory-KP.pem

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

### Step 3.3: Test Ansible Connectivity

```bash
# From repo root
cd ansible

# Test connection to web server
ansible web1 -i inventory.ini -m ping

# Test connection to db server
ansible db1 -i inventory.ini -m ping
```

**Expected Output:**
```
web1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### Step 3.4: Run Ansible Playbooks

```bash
cd ansible

# Configure web server
ansible-playbook web.yml -i inventory.ini -v

# Configure database server
ansible-playbook db.yml -i inventory.i -v

# Or run all in one
ansible-playbook site.yml -i inventory.ini -v
```

**Expected Actions:**
- Install packages (git, nodejs, npm, nginx, etc.)
- Clone TravelMemory repo to `/home/ubuntu/travelmemory`
- Create systemd services for backend
- Configure nginx as reverse proxy

---

## PHASE 4: Web Server Verification & Setup

### Step 4.1: SSH into Web Server

```bash
# Get the web server public IP from Terraform
WEB_PUBLIC_IP=$(terraform output -raw web_public_ip)

# SSH into the web server (bastion)
ssh -i ~/.ssh/travelMemory-KP.pem ubuntu@$WEB_PUBLIC_IP
```

> If the private DB host is not directly reachable from your laptop, use the web server as a bastion.

#### SSH to the private DB host via the bastion

From your laptop:
```bash
ssh -i ~/.ssh/travelMemory-KP.pem ubuntu@$WEB_PUBLIC_IP
```

On the bastion/web host:
```bash
# If the private key is not already on the bastion
scp -i ~/.ssh/travelMemory-KP.pem ~/.ssh/travelMemory-KP.pem ubuntu@$WEB_PUBLIC_IP:/home/ubuntu/
chmod 400 /home/ubuntu/travelMemory-KP.pem
ssh -i /home/ubuntu/travelMemory-KP.pem ubuntu@172.31.43.42
```

Or from your laptop in one step using ProxyJump:
```bash
ssh -o IdentitiesOnly=yes -i ~/.ssh/travelMemory-KP.pem -J ubuntu@$WEB_PUBLIC_IP ubuntu@172.31.43.42
```

### Step 4.2: Verify Installed Packages

```bash
# Check Git
git --version

# Check Node
node -v

# Check npm
npm -v

# Check Nginx
sudo nginx -v

# Check backend systemd service exists
sudo systemctl status travelmemory-backend
```

### Step 4.3: Verify Repository Cloned

```bash
ls -la /home/ubuntu/travelmemory/
# Should show: backend/, frontend/, ansible/, Terraform/, etc.
```

### Step 4.4: Build Frontend

```bash
cd /home/ubuntu/travelmemory/frontend

# Install dependencies
npm install

# Build production bundle
npm run build

# Verify build output
ls -la build/
```

**If permission errors (`EACCES`):**
```bash
# Fix ownership, remove existing node modules, reinstall, and build
sudo chown -R ubuntu:ubuntu /home/ubuntu/travelmemory
cd /home/ubuntu/travelmemory/frontend
# Remove old installs and lockfile
rm -rf node_modules package-lock.json
# Verify npm cache and install as the ubuntu user
npm cache verify
npm install
# Build production bundle
npm run build
```

### Step 4.5: Check Backend `.env` File

```bash
cat /home/ubuntu/travelmemory/backend/.env
```

**Expected contents:**
```
MONGO_URI=mongodb+srv://senharishms108:BhmebRock%21@atlas-cluster-harish-27.7gyzfqt.mongodb.net/travelmemory?retryWrites=true&w=majority
PORT=3001
NODE_ENV=production
```

**⚠️ Important:** Password special chars (especially `!`) must be URL-encoded as `%21`, and `@` as `%40`. Use the exact Atlas cluster host shown in your Atlas connection string.

### Step 4.6: Start/Restart Services

```bash
# Reload systemd daemon
sudo systemctl daemon-reload

# Start backend service
sudo systemctl start travelmemory-backend

# Restart Nginx
sudo systemctl restart nginx

# Check status
sudo systemctl status travelmemory-backend
sudo systemctl status nginx
```

### Step 4.7: Verify Nginx Configuration

```bash
# Check Nginx is listening on port 80
sudo ss -tlnp | grep nginx

# Expected output:
# LISTEN    0    128    0.0.0.0:80    0.0.0.0:*    users:(("nginx",pid=1234,fd=6))
```

---

## PHASE 5: Database & Integration Verification

### Step 5.1: MongoDB Atlas Connectivity Check

```bash
# From web server, update backend code and dependencies
cd /home/ubuntu/travelmemory/backend
git pull origin main
npm install

# Verify the current MongoDB URI used by the backend
grep '^MONGO_URI=' /home/ubuntu/travelmemory/backend/.env

# Then test MongoDB Atlas connectivity directly
npm run check-mongo

# Expected output:
# MongoDB connection OK
```

If `grep` shows an unencoded `@` inside the password, fix it in `/home/ubuntu/travelmemory/backend/.env` by replacing `@` with `%40`.

```bash
# Then verify backend health
curl http://localhost:3001/hello

# Expected output:
# Hello from TravelMemory Backend
```

If authentication still fails, reset the Atlas user's password in the Atlas Console for user `senharishms108` and confirm the password is exactly `BhmebRock!`.

### Step 5.2: Check Backend Logs

```bash
# Tail backend service logs
sudo journalctl -u travelmemory-backend -f

# Or check last 50 lines
sudo journalctl -u travelmemory-backend -n 50
```

**Look for:**
- ✅ "MongoDB connected successfully"
- ❌ Connection timeouts or auth failures

### Step 5.3: Check Nginx Logs

```bash
# Error log
sudo tail -n 50 /var/log/nginx/error.log

# Access log
sudo tail -n 50 /var/log/nginx/access.log
```

### Step 5.4: MongoDB Atlas Network Access

If backend cannot connect to MongoDB:

1. Get web server public IP:
   ```bash
   curl https://checkip.amazonaws.com
   ```

2. Add to MongoDB Atlas **Network Access**:
   - Go to Atlas Console → Network Access
   - Click **Add IP Address**
   - Add your web server IP (e.g., `13.234.111.115/32`)

3. Verify in MongoDB **Database Access**:
   - Confirm username/password are correct
   - Ensure database user has access to `travelmemory` database

---

## PHASE 6: Application Access & End-to-End Testing

### Step 6.1: Access the Application

```bash
# Get web server public IP
WEB_PUBLIC_IP=$(terraform output -raw web_public_ip)

# Open in browser
http://$WEB_PUBLIC_IP
# Example: http://13.233.16.231
```

### Step 6.2: Test Core Functionality

**From browser:**
1. Load home page
2. Navigate to "Add Experience"
3. Add a test experience
4. Verify it appears in the list
5. Click on an experience to view details

**From terminal (API tests):**
```bash
# Get all trips (backend API)
curl http://13.233.16.231:3001/trips

# Create a test trip
curl -X POST http://13.233.16.231:3001/trips \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Trip",
    "location": "Test City",
    "date": "2026-06-04",
    "description": "Test experience"
  }'
```

### Step 6.3: File Permission Checks

```bash
# Verify ownership
ls -la /home/ubuntu/travelmemory

# Should show:
# drwxr-xr-x ubuntu ubuntu backend
# drwxr-xr-x ubuntu ubuntu frontend
# etc.
```

---

## PHASE 7: Troubleshooting & Common Issues

### Service not starting?
```bash
# Check service status
sudo systemctl status travelmemory-backend

# Restart service
sudo systemctl restart travelmemory-backend

# Reload daemon if .service file changed
sudo systemctl daemon-reload
```

### Frontend build fails?
```bash
# Clear node_modules and cache
cd /home/ubuntu/travelmemory/frontend
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
npm run build
```

### Nginx returning 502 Bad Gateway?
```bash
# Check backend is running
sudo systemctl status travelmemory-backend

# Check backend listening on port 3001
sudo ss -tlnp | grep 3001

# Restart both services
sudo systemctl restart travelmemory-backend
sudo systemctl restart nginx
```

### MongoDB connection timeout?
```bash
# Add web server IP to MongoDB Atlas Network Access (see Phase 5.4)
# Verify .env has correct MONGO_URI
cat /home/ubuntu/travelmemory/backend/.env

# Test connection directly
curl -v http://localhost:3001/hello
```

---

## Git Commands (if making changes)

```bash
# Stage all changes
git add .

# Commit with message
git commit -m "Your descriptive message"

# Push to remote
git push
```

---

## Quick Reference: Key IPs & Ports

| Service | Host | Port | URL |
|---------|------|------|-----|
| Frontend (Nginx) | Web Server | 80 | `http://<WEB_PUBLIC_IP>` |
| Backend API | Web Server | 3001 | `http://<WEB_PUBLIC_IP>:3001` |
| MongoDB | Atlas (Cloud) | 27017 | Connection string in `.env` |
| SSH | Web/DB Server | 22 | `ssh -i key.pem ubuntu@<IP>` |

---

## Complete Workflow Summary

1. **Install tools** (Terraform, AWS CLI, Ansible)
2. **Configure AWS credentials** (aws configure)
3. **Run Terraform** (init → plan → apply)
4. **Capture Terraform outputs** (web_public_ip, db_private_ip)
5. **Update Ansible inventory** (with IPs from step 4)
6. **Run Ansible playbooks** (site.yml)
7. **SSH to web server** (verify packages, build frontend)
8. **Check services** (backend running, nginx listening)
9. **Verify database** (MongoDB Atlas connectivity)
10. **Test application** (browser & API)

---

## Support & Logging

For detailed logs and debugging:

```bash
# Terraform logs
TF_LOG=DEBUG terraform plan

# Ansible verbose
ansible-playbook site.yml -vvv

# Systemd journal
sudo journalctl -u travelmemory-backend -n 100 --no-pager
```