# Deployment & Verification Commands

This file collects the commands used during provisioning and the checks to verify the TravelMemory app.

## 0) Install Terraform and Configure AWS Credentials (if not already installed)
Run on your machine or EC2 instance before running Terraform commands:

### Step 0a: Install Terraform

**Option 1: Install via HashiCorp Repository (Recommended)**
```bash
cd ~
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform
terraform --version
```

### Step 0b: Configure AWS Credentials on EC2
If running Terraform from an **EC2 instance** (like your Jenkins-server), you need to configure AWS credentials.

**Option A: Install AWS CLI and configure manually**
```bash
sudo apt install -y awscli
aws configure
# Prompted to enter:
# AWS Access Key ID: [your-access-key]
# AWS Secret Access Key: [your-secret-key]
# Default region name: ap-south-1
# Default output format: json
```

**Option B: Set credentials as environment variables (quick method)**
```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="ap-south-1"
# Then run Terraform commands
```

**How to get AWS credentials:**
1. Go to AWS Console → IAM → Users → Your user
2. Click **Security credentials** tab
3. Under **Access keys**, click **Create access key** (if none exist)
4. Copy the **Access Key ID** and **Secret Access Key**
5. Use them in `aws configure` or as environment variables above

**Verify credentials are set:**
```bash
aws sts get-caller-identity
```
You should see your AWS account ID and user info.

## 1) Local repo (Windows workstation)

### Step 1a: Get your variable values
Before running Terraform, you need two values:

1. **`YOUR_KEYPAIR`** - Your AWS EC2 Key Pair name
   - Go to AWS Console → EC2 → Key Pairs
   - Check the name of an existing key pair you have (e.g., `my-keypair`, `aws-key`)
   - Or create a new one and note its name

2. **`YOUR_IP`** - Your local machine's public IP (where you're running Terraform)
   - On Windows PowerShell: `(Invoke-WebRequest -Uri "https://checkip.amazonaws.com").Content`
   - Or visit: https://checkip.amazonaws.com
   - You'll get something like `203.0.113.45` → use `203.0.113.45/32`

### Step 1b: Initialize Terraform and plan/apply (in `Terraform/`)
```bash
cd Terraform
terraform init
terraform plan -out plan.tfplan \
  -var "aws_region=ap-south-1" \
  -var "key_name=capstone-project-KP" \
  -var "admin_cidr=13.127.59.251/32"
# Example:
# terraform plan -out plan.tfplan -var "aws_region=ap-south-1" -var "key_name=my-ec2-key" -var "admin_cidr=203.0.113.45/32"
terraform apply "plan.tfplan"
```

Note: `key_name` must match the AWS EC2 key pair name in the selected region. Do not include the local `.pem` file extension here; that file is only used locally for SSH access.

**⚠️ TROUBLESHOOTING: "InvalidKeyPair.NotFound" error**

If you get: `Error: creating EC2 Instance: InvalidKeyPair.NotFound: The key pair 'capstone-project-KP.pem' does not exist`

**This means the key pair you specified doesn't exist in your AWS account.**

**Solution:**
1. **Find existing key pairs** in AWS Console → EC2 → Key Pairs
   - Note the name of an existing pair (without the `.pem` extension)
   
2. **OR create a new key pair:**
   ```bash
   # On your local machine (Windows PowerShell or terminal):
   aws ec2 create-key-pair --key-name my-new-key --region ap-south-1 --query 'KeyMaterial' --output text > my-new-key.pem
   chmod 400 my-new-key.pem  # (on Linux/Mac, not needed on Windows)
   ```

3. **Then destroy and re-apply with the correct key pair name:**
   ```bash
   # On EC2 instance:
   cd ~/TravelMemory/Terraform
   terraform destroy  # (type 'yes' when prompted)
   
   # Now apply with correct key pair:
   terraform plan -out plan.tfplan -var "key_name=my-new-key" -var "admin_cidr=13.127.59.251/32"
   terraform apply "plan.tfplan"
   ```

- Note outputs:
```bash
terraform output web_public_ip
terraform output db_private_ip
```

## 2) Ansible control machine (your local dev or the web server itself)
- Ensure `ansible` is installed (on Ubuntu):
```bash
sudo apt update
sudo apt install ansible-core -y
```
- Update `ansible/inventory.ini` with the web public IP and key file path (example already prepared):
- Run the full playbook (when bastion/proxy is available):
```bash
cd ansible
ansible-playbook site.yml
```
- Or to run only web configuration locally on the web server:
```bash
cd ansible
ansible-playbook web.yml -i "localhost," -c local
```

## 3) Commands executed on the web server (EC2 Ubuntu) — common checks & fixes
- Install missing packages (if needed):
```bash
sudo apt update
sudo apt install -y git curl nginx nodejs npm
```
- Build frontend:
```bash
cd /home/ubuntu/travelmemory/frontend
npm install
npm run build
```
- Fix build permissions if you see `EACCES`:
```bash
sudo chown -R ubuntu:ubuntu /home/ubuntu/travelmemory
rm -rf /home/ubuntu/travelmemory/frontend/build
npm run build
```
- Check nginx is listening on port 80:
```bash
sudo ss -tlnp | grep nginx
```
- Check backend `.env` (MongoDB Atlas URI must be URL-encoded for special chars):
```bash
cat /home/ubuntu/travelmemory/backend/.env
# Example value
# MONGO_URI=mongodb+srv://senharishms108:BtnHurryPot%4026@atlas-cluster-harish-27.7gyzfqt.mongodb.net/travelmemory?retryWrites=true&w=majority
```
- Restart services and check status:
```bash
sudo systemctl daemon-reload
sudo systemctl restart travelmemory-backend
sudo systemctl restart nginx
sudo systemctl status travelmemory-backend
sudo systemctl status nginx
```
- Tail backend logs:
```bash
sudo journalctl -u travelmemory-backend -f
```
- Tail nginx logs:
```bash
sudo tail -n 200 /var/log/nginx/error.log
sudo tail -n 200 /var/log/nginx/access.log
```
- Quick backend health check:
```bash
curl http://localhost:3001/hello
```

## 4) MongoDB Atlas checks
- If `AtlasError` or handshake/auth fails:
  - URL-encode `@` in password as `%40`.
  - Ensure Atlas **Network Access** allows the web server IP (add `13.234.111.115/32` or appropriate public IP).
  - Verify username/password in Atlas **Database Access** and the database name.

## 5) Git commands used to record changes
```bash
# Stage and commit
git add .
git commit -m "Your message"
git push
```

## 6) Useful troubleshooting commands
```bash
# Check file ownership
ls -la /home/ubuntu/travelmemory

# Check Node version
node -v

# Check npm
npm -v
```

## 7) How to access the app
- Open browser and go to:
```
http://<WEB_PUBLIC_IP>
# example: http://13.234.111.115
```

---
If you want, I can also add a short script to automate the most common verification steps on the server.