# Deployment & Verification Commands

This file collects the commands used during provisioning and the checks to verify the TravelMemory app.

## 1) Local repo (Windows workstation)
- Initialize Terraform and plan/apply (in `Terraform/`):
```bash
cd Terraform
terraform init
terraform plan -out plan.tfplan -var "key_name=YOUR_KEYPAIR" -var "admin_cidr=YOUR_IP/32"
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