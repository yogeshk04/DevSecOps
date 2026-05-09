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

```
┌──────────────────────────────────────────────────────────┐
│                   Docker Network                          │
├──────────────────────────────────────────────────────────┤
│                                                            │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────┐ │
│  │   Frontend   │────▶│   Backend    │────▶│PostgreSQL│ │
│  │  (React +    │◀────│ (Node.js +   │◀────│  (DB)    │ │
│  │   Nginx)     │     │  Express)    │     │          │ │
│  │ Port 80:8080 │     │ Port 5000    │     │ Port5432 │ │
│  └──────────────┘     └──────────────┘     └──────────┘ │
│                                                            │
│  • read_only: true    • health checks      • persistence │
│  • no-new-priv        • depends_on db      • pgdata vol  │
│                                                            │
└──────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
DevSecOps/
├── frontend/                    # React (Vite) frontend
│   ├── src/                     # React components & pages
│   ├── Dockerfile               # Frontend container image
│   ├── nginx.conf               # Nginx reverse proxy config
│   └── package.json
├── backend/                     # Node.js Express API
│   ├── src/                     # Routes, middleware, controllers
│   ├── Dockerfile               # Backend container image
│   ├── .env.example             # Environment variables template
│   └── package.json
├── docker-compose.yml           # Multi-container orchestration
├── deploy/                      # Deployment scripts
│   ├── setup.sh                 # EC2 setup automation
│   └── jerney-nginx.conf        # Nginx reverse proxy config
├── README.md                    # This file
└── .gitignore
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

## 🚀 Deploy on AWS EC2

### Prerequisites

- AWS EC2 instance running **Ubuntu 22.04+**
- Security Group allowing inbound:
  - Port **22** (SSH)
  - Port **80** (HTTP)
- SSH key pair configured

### Step 1: Transfer Code to EC2

```bash
scp -r -i your-key.pem ./ ubuntu@<EC2_PUBLIC_IP>:~/DevSecOps
```

### Step 2: SSH into Instance

```bash
ssh -i your-key.pem ubuntu@<EC2_PUBLIC_IP>
```

### Step 3: Run Setup Script

```bash
cd ~/DevSecOps
chmod +x deploy/setup.sh
./deploy/setup.sh
```

**Setup script performs:**
1. System package updates
2. Node.js 20.x installation
3. PostgreSQL 16 setup with database initialization
4. Nginx configuration as reverse proxy
5. PM2 for process management
6. Backend dependency installation
7. React frontend build
8. Service startup and auto-restart configuration

### Step 4: Access Application

```
http://<EC2_PUBLIC_IP>
```

### Useful EC2 Commands

```bash
# Backend process management
pm2 status                          # View all PM2 processes
pm2 logs                            # Stream backend logs
pm2 restart all                     # Restart backend
pm2 stop all                        # Stop backend

# Nginx management
sudo systemctl status nginx         # Check Nginx status
sudo systemctl restart nginx        # Restart Nginx
sudo nginx -t                       # Test Nginx config

# Database access
sudo -u postgres psql -d devsecops_db
```

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
| `main` | Production-ready code + EC2 deployment | EC2 bare-metal |
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

## 📚 Resources

- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL 16 Docs](https://www.postgresql.org/docs/16/)
- [Node.js Express Guide](https://expressjs.com/)
- [React Documentation](https://react.dev/)

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Last Updated:** May 9, 2026