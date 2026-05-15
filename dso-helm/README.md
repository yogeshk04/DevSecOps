# dso-helm — DevSecOps Blog Platform Helm Chart

Helm chart for deploying the DevSecOps Blog Platform (React + Node.js + PostgreSQL)
on a local **kind** or **Docker Desktop** Kubernetes cluster.

---

## Chart Contents

| Template | Resource |
|---|---|
| `namespace.yaml` | Namespace (managed by this chart) |
| `secret.yaml` | PostgreSQL credentials (Opaque Secret) |
| `storageclass.yaml` | Local `StorageClass` (no external provisioner) |
| `pv.yaml` | `PersistentVolume` backed by a host path |
| `pvc.yaml` | `PersistentVolumeClaim` for PostgreSQL data |
| `db-statefulset.yaml` | PostgreSQL Deployment |
| `db-service.yaml` | PostgreSQL ClusterIP Service |
| `backend-deployment.yaml` | Node.js API Deployment (init container waits for DB) |
| `backend-service.yaml` | Backend ClusterIP Service |
| `frontend-configmap.yaml` | Nginx server block (proxy\_pass uses Helm service DNS) |
| `frontend-deployment.yaml` | React + Nginx Deployment |
| `frontend-service.yaml` | Frontend NodePort Service |
| `networkpolicy.yaml` | DB ← backend only; backend ← frontend only |
| `ingress.yaml` | Optional Ingress (disabled by default) |

---

## Prerequisites

| Tool | Version | Install |
|---|---|---|
| Docker Desktop | 4.x+ | https://www.docker.com/products/docker-desktop |
| kind | 0.22+ | `winget install Kubernetes.kind` |
| kubectl | 1.28+ | Bundled with Docker Desktop |
| Helm | 3.14+ | `winget install Helm.Helm` |

---

## Step 1 — Build Local Docker Images

The chart uses locally built images (`pullPolicy: IfNotPresent`).
Build them from the project root:

```powershell
# From D:\Learn-more\Projects\DevSecOps
docker build -t devsecops-backend:latest ./backend
docker build -t devsecops-frontend:latest ./frontend
```

Verify they exist:

```powershell
docker images --filter "reference=devsecops*"
```

---

## Step 2 — Create a kind Cluster

> Skip this step if you already have a running kind cluster.

A `kind-config.yaml` at the project root pre-configures port mappings so
NodePort services are reachable at `localhost` on Windows:

```powershell
kind create cluster --name desktop --config kind-config.yaml
```

Verify the cluster is active:

```powershell
kubectl get nodes
# NAME                    STATUS   ROLES           AGE
# desktop-control-plane   Ready    control-plane   ...
# desktop-worker          Ready    <none>          ...
```

---

## Step 3 — Load Images into kind

kind nodes are Docker containers with their own containerd namespace.
Images must be explicitly loaded:

```powershell
kind load docker-image devsecops-backend:latest  --name desktop
kind load docker-image devsecops-frontend:latest --name desktop
kind load docker-image postgres:16-alpine         --name desktop
```

---

## Step 4 — Create Storage Directory

The PostgreSQL PersistentVolume uses a host path. Create the directory on
your Windows host before deploying:

```powershell
mkdir D:\dso-storage
```

> On kind, Docker Desktop maps `D:\` into node containers at
> `/run/desktop/mnt/host/d/`. The `hostPath` value in `values.yaml` already
> points to this path.

---

## Step 5 — Deploy with Helm

### Dev environment (recommended for local testing)

```powershell
helm install dso-dev .\dso-helm\ -f .\dso-helm\values-dev.yaml
```

This overrides:
- `namespace` → `dev`
- `replicaCount` → `1` for both backend and frontend
- `frontend.service.nodePort` → `30081`

### Default environment

```powershell
helm install dso .\dso-helm\
```

---

## Step 6 — Verify Pods are Running

```powershell
kubectl get pods -n dev -w
```

Expected output once all pods are healthy:

```
NAME                                         READY   STATUS    RESTARTS   AGE
dso-dev-dso-helm-backend-<hash>              1/1     Running   0          60s
dso-dev-dso-helm-db-<hash>                   1/1     Running   0          60s
dso-dev-dso-helm-frontend-<hash>             1/1     Running   0          60s
```

> The backend pod starts an init container that waits for PostgreSQL to be
> ready. It is normal to see `Init:0/1` for 10–20 seconds.

---

## Step 7 — Access the Application

### Via port-forward (works on all kind clusters)

```powershell
kubectl port-forward -n dev svc/dso-dev-dso-helm-frontend 8080:80
```

Open in browser: **http://localhost:8080**

> Keep the terminal open while using the app. Press `Ctrl+C` to stop.

### Verify backend health (optional)

```powershell
kubectl port-forward -n dev svc/dso-dev-dso-helm-backend 5000:5000
# In a second terminal:
curl http://localhost:5000/api/health
```

---

## Upgrading

After changing values or templates:

```powershell
# Dev environment
helm upgrade dso-dev .\dso-helm\ -f .\dso-helm\values-dev.yaml

# Default environment
helm upgrade dso .\dso-helm\
```

After rebuilding images, reload them into kind then upgrade:

```powershell
docker build -t devsecops-backend:latest ./backend
docker build -t devsecops-frontend:latest ./frontend
kind load docker-image devsecops-backend:latest  --name desktop
kind load docker-image devsecops-frontend:latest --name desktop
helm upgrade dso-dev .\dso-helm\ -f .\dso-helm\values-dev.yaml
```

---

## Uninstalling

```powershell
# This also deletes the 'dev' namespace and all resources inside it
helm uninstall dso-dev
```

---

## Values Reference

| Key | Default | Description |
|---|---|---|
| `namespace` | `dev` | Kubernetes namespace to deploy into |
| `db.auth.username` | `devsecops_user` | PostgreSQL username |
| `db.auth.password` | `devsecops_pass_2026` | PostgreSQL password |
| `db.auth.database` | `devsecops_db` | PostgreSQL database name |
| `storage.size` | `10Gi` | PVC / PV capacity |
| `storage.storageClassName` | `devsecops-local-sc` | StorageClass name |
| `storage.hostPath` | `/run/desktop/mnt/host/d/dso-storage` | Host path inside kind node |
| `backend.image.repository` | `devsecops-backend` | Backend image name |
| `backend.image.tag` | `latest` | Backend image tag |
| `backend.image.pullPolicy` | `IfNotPresent` | Image pull policy |
| `backend.replicaCount` | `1` | Backend replica count |
| `backend.port` | `5000` | Backend container port |
| `frontend.image.repository` | `devsecops-frontend` | Frontend image name |
| `frontend.image.tag` | `latest` | Frontend image tag |
| `frontend.image.pullPolicy` | `IfNotPresent` | Image pull policy |
| `frontend.replicaCount` | `1` | Frontend replica count |
| `frontend.port` | `8080` | Frontend container port |
| `frontend.service.type` | `NodePort` | Service type |
| `frontend.service.nodePort` | `30080` | NodePort (overridden to `30081` in dev) |
| `ingress.enabled` | `false` | Enable Ingress resource |

---

## Troubleshooting

### `ErrImageNeverPull` or `ErrImagePull`

Images are not loaded into the kind node. Run:

```powershell
kind load docker-image devsecops-backend:latest  --name desktop
kind load docker-image devsecops-frontend:latest --name desktop
```

### Frontend `CrashLoopBackOff` — nginx upstream not found

The nginx ConfigMap uses the Helm-generated service DNS name. Ensure you
deployed with the correct release name and values file. The ConfigMap is
rendered at deploy time with the correct `proxy_pass` host.

### Pod stuck in `Init:0/1`

The init container is waiting for PostgreSQL. Check DB pod status:

```powershell
kubectl get pods -n dev
kubectl logs -n dev -l app.kubernetes.io/component=database
```

### `port-forward` exits immediately

Check the frontend pod is actually `Running`:

```powershell
kubectl get pods -n dev
# Then re-run:
kubectl port-forward -n dev svc/dso-dev-dso-helm-frontend 8080:80
```

### Existing namespace blocks `helm install`

If a stale namespace exists from a previous failed install, adopt it:

```powershell
kubectl label namespace dev app.kubernetes.io/managed-by=Helm --overwrite
kubectl annotate namespace dev meta.helm.sh/release-name=dso-dev meta.helm.sh/release-namespace=default --overwrite
helm install dso-dev .\dso-helm\ -f .\dso-helm\values-dev.yaml
```
