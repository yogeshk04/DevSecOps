# 🛤️ DevSecOps Blog Platform

A modern 3-tier blog application demonstrating DevSecOps best practices with React frontend, Node.js backend, and PostgreSQL database. Includes Docker containerization, security hardening, and deployment automation.

![Tech Stack](https://img.shields.io/badge/React-18-61DAFB?style=flat-square&logo=react)
![Tech Stack](https://img.shields.io/badge/Node.js-20-339933?style=flat-square&logo=node.js)
![Tech Stack](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat-square&logo=postgresql)
![Tech Stack](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat-square&logo=docker)
![Tech Stack](https://img.shields.io/badge/Security-Hardened-FF6B6B?style=flat-square)

---

> [!IMPORTANT]
> **DevSecOps Implementation**
> 
> This repository demonstrates complete DevSecOps practices:
> - Docker containerization with security hardening
> - Health checks and service dependencies
> - Read-only filesystems and privilege escalation prevention
> - Database persistence with named volumes
> - 3-tier architecture with service isolation
>
> ```bash
> docker-compose up -d
> ```

---

## ✨ Features

- 📝 **Create blog posts** with rich text support
- ✏️ **Edit existing posts** with real-time updates
- 🗑️ **Delete posts** with confirmation
- 💬 **Comment system** with nested support
- 🔒 **Security-first design** with hardened containers
- 🐳 **Docker containerization** for consistent deployments
- 📊 **Health checks** ensuring service availability
- 🛡️ **Database persistence** with volume management

## 🏗️ Architecture

Brief flow:

```text
Client Browser
  |
  v
Frontend (React + Nginx)
  |
  v
Backend API (Node.js + Express)
  |
  v
PostgreSQL (Persistent Storage)
```

Deployment options in this repo:
- Docker Compose for local multi-container runs
- Raw Kubernetes manifests (`k8s-manifest.yaml`, `pod.yml`)
- Helm charts (`helm/` and `dso-helm/`) for templated K8s deployments

## 📁 Project Structure

```text
DevSecOps/
├── backend/                # Express API + PostgreSQL integration
├── frontend/               # React (Vite) app served by Nginx
├── docker-compose.yml      # Local 3-tier orchestration
├── k8s-manifest.yaml       # Single-file Kubernetes manifest set
├── pod.yml                 # Additional Kubernetes pod manifest
├── kind-config.yaml        # kind cluster configuration
├── helm/                   # Base Helm chart
├── dso-helm/               # Main Helm chart (templates + values)
└── README.md
```

---

## 🐳 Quick Start with Docker Compose

### Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 2GB free disk space

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd DevSecOps
```

### Step 2: Start All Services

```bash
# Start all containers in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Check service status
docker-compose ps
```

### Step 3: Access the Application

```
Frontend:  http://localhost
Backend:   http://localhost:5000
Database:  localhost:5432
```

### Step 4: Verify Health Status

```bash
# Check database health
docker-compose exec db pg_isready -U devops_admin -d devsecops_db

# Check backend health
curl http://localhost:5000/api/health

# View all services
docker-compose ps
```

### Useful Docker Commands

```bash
# View logs for a specific service
docker-compose logs backend
docker-compose logs frontend
docker-compose logs db

# Stop all services
docker-compose down

# Remove volumes (⚠️ deletes data)
docker-compose down -v

# Rebuild containers
docker-compose build --no-cache

# Execute command in running container
docker-compose exec backend npm run seed
```

---

## 🚀 Deploy on Kubernetes (Helm)

### Prerequisites

- Kubernetes cluster (kind or Docker Desktop Kubernetes)
- Helm 3.x
- `kubectl` configured for your cluster

### Deploy Steps

```bash
# From repository root
helm upgrade --install dso ./dso-helm -n dev --create-namespace

# Check rollout
kubectl get pods -n dev
kubectl get svc -n dev
```

### Access Application

By default, the frontend service is `NodePort` on `30080`:

```text
http://localhost:30080
```

Optional port-forward:

```bash
kubectl port-forward -n dev svc/dso-dev-dso-helm-frontend 8080:80
```

Then open `http://localhost:8080`

---

## 🧑‍💻 Local Development

### Prerequisites

- Node.js 20+
- PostgreSQL 16+
- npm or yarn

### Backend Setup

```bash
cd backend
npm install

# Create .env file
cat > .env << EOF
PORT=5000
DB_HOST=localhost
DB_PORT=5432
DB_USER=devops_admin
DB_PASSWORD=SecureDevOps2026!
DB_NAME=devsecops_db
NODE_ENV=development
EOF

# Start backend server
npm start
```

Backend runs on: `http://localhost:5000`

### Frontend Setup

```bash
cd frontend
npm install

# Start Vite dev server
npm run dev
```

Frontend runs on: `http://localhost:3000`

**Note:** Vite automatically proxies `/api` requests to `http://localhost:5000`

### Database Setup (Local PostgreSQL)

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database and user
CREATE USER devops_admin WITH PASSWORD 'SecureDevOps2026!';
CREATE DATABASE devsecops_db OWNER devops_admin;
GRANT ALL PRIVILEGES ON DATABASE devsecops_db TO devops_admin;

# Connect to database
\c devsecops_db

# Run initialization scripts (if any exist in backend/scripts)
```

---

## 📡 API Endpoints

### Posts Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check / API status |
| GET | `/api/posts` | Get all posts with pagination |
| GET | `/api/posts/:id` | Get single post with all comments |
| POST | `/api/posts` | Create a new post |
| PUT | `/api/posts/:id` | Update an existing post |
| DELETE | `/api/posts/:id` | Delete a post |

### Comments Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/comments/post/:postId` | Get all comments for a post |
| POST | `/api/comments` | Create a new comment |
| DELETE | `/api/comments/:id` | Delete a comment |

### Example Requests

```bash
# Get health status
curl http://localhost:5000/api/health

# Get all posts
curl http://localhost:5000/api/posts

# Create a post
curl -X POST http://localhost:5000/api/posts \
  -H "Content-Type: application/json" \
  -d '{"title": "My Blog", "content": "Hello World"}'

# Get comments for post ID 1
curl http://localhost:5000/api/comments/post/1
```

---

## 🔒 Security Features

### Container Hardening

- **Read-only filesystem** on backend container
- **No privilege escalation** (`security_opt: no-new-privileges:true`)
- **Minimal tmpfs** for runtime requirements
- **Health checks** ensuring only healthy services handle traffic
- **Service isolation** via Docker network

### Database Security

- **Alpine Linux base image** (minimal attack surface)
- **Health checks** before dependent services start
- **Persistent volumes** with proper permissions
- **Restricted tmpfs** for temporary files
- **Environment-based credentials**

### Network Security

- **Backend not exposed** to host (internal only)
- **Frontend only exposes port 80**
- **Service-to-service communication** via Docker DNS

---

## 🌿 Branch Strategy

| Branch | Purpose | Deployment |
|--------|---------|------------|
| `main` | Production-ready code + stable releases | Kubernetes/Helm |
| `devops` | Full DevSecOps pipeline + K8s | Docker + EKS/K8s |
| `dev` | Development and testing | Local/staging |

---

## 📝 Environment Variables

### Backend (.env)

```env
PORT=5000
DB_HOST=db
DB_PORT=5432
DB_USER=devops_admin
DB_PASSWORD=SecureDevOps2026!
DB_NAME=devsecops_db
NODE_ENV=production
```

### Database (docker-compose.yml)

```yaml
POSTGRES_USER: devops_admin
POSTGRES_PASSWORD: SecureDevOps2026!
POSTGRES_DB: devsecops_db
```

---

## 🛠️ Troubleshooting

### Container Issues

```bash
# View detailed logs
docker-compose logs <service-name>

# Check container status
docker ps -a

# Inspect container configuration
docker inspect <container-name>
```

### Database Connection Issues

```bash
# Test database connectivity
docker-compose exec db pg_isready -U devops_admin

# Connect to database
docker-compose exec db psql -U devops_admin -d devsecops_db
```

### Backend Errors

```bash
# Check backend logs
docker-compose logs backend

# Rebuild backend image
docker-compose build --no-cache backend

# Restart backend service
docker-compose restart backend
```

---

## 📚 NetworkPolicies Details

The NetworkPolicies verification:

| Policy selector | Rendered value | Actual pod label | Match? |
|---|---|---|---|
| DB `podSelector` | `dso-dev-dso-helm-db` | `app.kubernetes.io/name=dso-dev-dso-helm-db` | ✅ |
| Allow from backend | `dso-dev-dso-helm-backend` | `app.kubernetes.io/name=dso-dev-dso-helm-backend` | ✅ |
| Backend `podSelector` | `dso-dev-dso-helm-backend` | `app.kubernetes.io/name=dso-dev-dso-helm-backend` | ✅ |
| Allow from frontend | `dso-dev-dso-helm-frontend` | `app.kubernetes.io/name=dso-dev-dso-helm-frontend` | ✅ |

**One gap to note:** The NetworkPolicies only define `Ingress` rules, which means there are no `Egress` restrictions. This is intentional for a local dev cluster (egress blocking would break DNS and external access), but worth knowing.

`port-forward` via the service (more stable than pod name):

```powershell
kubectl port-forward -n dev svc/dso-dev-dso-helm-frontend 8080:80
```

Then open `http://localhost:8080`

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.



---

**Last Updated:** May 15, 2026
