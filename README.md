# Travel Memory

Travel Memory is a full-stack travel journal application with a React frontend, Express backend, and MongoDB persistence. This repository includes both local development helpers and production-ready deployment guidance.

## Project structure

This repository contains the TravelMemory full-stack application and its deployment automation.

- `backend/` — Express API server, MongoDB connection, and models.
- `frontend/` — React application.
- `scripts/` — local startup and environment helper scripts.
- `Terraform/` — AWS infrastructure definitions.
- `ansible/` — server configuration and deployment automation.
- `POC/` — proof-of-concept documentation and deployment notes.
- `DEPLOYMENT_COMMANDS.md` — recommended deployment workflow and verification commands.
- `README.md` — this project overview and setup guide.

### Visual structure

```text
TravelMemory/
├── backend/
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   ├── conn.js
│   ├── index.js
│   ├── package.json
│   └── .env.example
├── frontend/
│   ├── public/
│   ├── src/
│   │   ├── components/
│   │   │   ├── pages/
│   │   │   └── UIC/
│   │   ├── App.js
│   │   └── url.js
│   ├── package.json
│   └── .env.example
├── scripts/
│   ├── start_backend.sh
│   ├── start_frontend.sh
│   └── install_and_start_all.sh
├── Terraform/
│   ├── provider.tf
│   ├── vpc.tf
│   ├── ec2.tf
│   ├── security.tf
│   ├── iam.tf
│   ├── variables.tf
│   └── outputs.tf
├── ansible/
│   ├── inventory.ini
│   ├── vars.yml
│   ├── site.yml
│   ├── db.yml
│   └── web.yml
├── POC/
│   ├── ansible.md
│   ├── backend.md
│   ├── commands.md
│   ├── frontend.md
│   ├── mongo.md
│   ├── README.md
│   └── terraform.md
├── DEPLOYMENT_COMMANDS.md
├── DEPLOYMENT_REPORT.md
└── LICENSE
```

## Code Layout

- `frontend/` — React application
- `backend/` — Express API server and MongoDB models
- `scripts/` — local startup, install, and provisioning helpers
- `Terraform/` — AWS infrastructure definitions
- `ansible/` — server configuration automation
- `DEPLOYMENT_COMMANDS.md` — recommended deployment workflow and verification steps

## Prerequisites

- Node.js 18.x or 20.x LTS
- npm 10.x or compatible
- MongoDB Atlas or local MongoDB server
- Linux/Ubuntu for provided shell automation
- AWS account and credentials for Terraform/Ansible deployment

## Environment Configuration

### Backend

Use `backend/.env.example` as a template. Production must use secure secrets and no credentials in source control.

Example `backend/.env`:

```bash
PORT=3001
MONGO_URI='mongodb+srv://<user>:<password>@<cluster>/travelmemory?retryWrites=true&w=majority'
```

Example local development `backend/.env`:

```bash
PORT=3001
MONGO_URI=mongodb://127.0.0.1:27017/travelmemory
```

### Frontend

Use `frontend/.env.example` as a template.

Example `frontend/.env`:

```bash
REACT_APP_BACKEND_URL=http://localhost:3001
```

In production, set REACT_APP_BACKEND_URL to the public backend URL or proxy endpoint.

### Secrets Handling

- Never commit .env files or secrets to Git.
- .gitignore already excludes .env and other local environment files.
- Use a secrets manager for production: AWS Secrets Manager, HashiCorp Vault, or equivalent.
- Use separate credentials for development, staging, and production.

## Local Development

### Start local MongoDB

If using local MongoDB, start it first:

```bash
sudo systemctl enable --now mongod
sudo systemctl status mongod
```

### Run backend locally

```bash
cd backend
npm install
node index.js
```

Or use the helper script (run from WSL or Git Bash on Windows):

```bash
bash scripts/start_backend.sh
```

Verify the backend:

```bash
curl http://localhost:3001/hello
```

Verify MongoDB connection:

```bash
cd backend
npm run check-mongo
```

### Run frontend locally

```bash
cd frontend
npm install
npm start
```

Or use the helper script:

```bash
bash scripts/start_frontend.sh
```

Open the app at http://localhost:3000.

## Useful commands

### Local development commands

- Start backend:
  ```bash
  cd backend
  npm install
  node index.js
  ```
- Start frontend:
  ```bash
  cd frontend
  npm install
  npm start
  ```
- Run backend helper script:
  ```bash
  bash scripts/start_backend.sh
  ```
- Run frontend helper script:
  ```bash
  bash scripts/start_frontend.sh
  ```
- Verify backend health:
  ```bash
  curl http://localhost:3001/hello
  ```
- Verify MongoDB connectivity:
  ```bash
  cd backend
  npm run check-mongo
  ```

### MongoDB commands

- Start MongoDB:
  ```bash
  sudo systemctl enable --now mongod
  sudo systemctl status mongod
  ```
- Stop MongoDB:
  ```bash
  sudo systemctl stop mongod
  ```
- Restart MongoDB:
  ```bash
  sudo systemctl restart mongod
  ```
- Check MongoDB port:
  ```bash
  sudo ss -tulpn | grep 27017
  sudo lsof -i :27017
  ```
- View MongoDB logs:
  ```bash
  sudo journalctl -u mongod -n 50
  sudo journalctl -u mongod -f
  ```

### Troubleshooting ports

- Check frontend port 3000:
  ```bash
  sudo lsof -i :3000
  sudo ss -tulpn | grep 3000
  ```
- Check backend port 3001:
  ```bash
  sudo lsof -i :3001
  sudo ss -tulpn | grep 3001
  ```
- Kill process using port 3001:
  ```bash
  sudo fuser -n tcp 3001 -k
  ```
- Kill process using port 3000:
  ```bash
  sudo fuser -n tcp 3000 -k
  ```

## Production Readiness

The application is ready for production when the following practices are in place.

### Backend production deployment

Do not run the backend with `node index.js` directly in production.
Use a process manager or systemd service:

- PM2 example:
  ```bash
  cd backend
  npm install
  pm2 start index.js --name travelmemory-backend --env production
  pm2 save
  ```
- systemd example:
  - Configure a service unit that runs the backend from the backend folder
  - Load environment variables from a secure source
  - Enable auto-start on boot

### Frontend production deployment

Build and serve the frontend as a static site:

```bash
cd frontend
npm install
npm run build
```

Serve `frontend/build/` using Nginx, Apache, or a managed CDN.

### MongoDB production guidance

- Use MongoDB Atlas or a managed database service.
- Create a dedicated app user with least privilege.
- Enable TLS/SSL.
- Restrict network access to the application servers only.
- Do not store credentials in code.

### Security and reliability

- Use HTTPS for all frontend and backend traffic.
- Configure CORS only for trusted origins.
- Keep Node.js on a supported LTS release.
- Do not expose internal or debug endpoints.
- Enable centralized logging and monitoring.
- Implement health checks and readiness endpoints.

### Production checklist

- [ ] .env files are not committed
- [ ] Production secrets stored securely
- [ ] Backend managed by PM2 or systemd
- [ ] Frontend served from a build artifact
- [ ] HTTPS enabled
- [ ] CORS restricted to trusted origins
- [ ] MongoDB access restricted and audited
- [ ] Monitoring and alerting configured
- [ ] Backups configured and tested

## Startup Scripts

### scripts/start_backend.sh

- Changes to backend
- Installs dependencies
- Copies `backend/.env.example` to `backend/.env` if missing
- Starts the backend with `node index.js`

### scripts/start_frontend.sh

- Changes to frontend
- Installs dependencies
- Copies `frontend/.env.example` to `frontend/.env` if missing
- Starts the React development server with `npm start`

### scripts/install_and_start_all.sh

- Installs MongoDB on Ubuntu
- Starts mongod
- Installs backend/frontend dependencies
- Starts the backend and frontend services locally

## Deployment automation

Use the provided `Terraform/` and `ansible/` assets for AWS deployment.

- `Terraform/` defines infrastructure resources.
- `ansible/` configures servers and deploys the app.
- `DEPLOYMENT_COMMANDS.md` contains the full provisioning and verification workflow.

## Trip data format

Example payload for the trip API:

```json
{
  "tripName": "Incredible India",
  "startDateOfJourney": "2022-03-19",
  "endDateOfJourney": "2022-03-27",
  "nameOfHotels": "Hotel Namaste, Backpackers Club",
  "placesVisited": "Delhi, Kolkata, Chennai, Mumbai",
  "totalCost": 800000,
  "tripType": "leisure",
  "experience": "Lorem ipsum dolor sit amet...",
  "image": "https://t3.ftcdn.net/jpg/03/04/85/26/360_F_304852693_nSOn9KvUgafgvZ6wM0CNaULYUa7xXBkA.jpg",
  "shortDescription": "India is a wonderful country with rich culture and good people.",
  "featured": true
}
```
