# Adria Reserve — Containerized Architecture (Kubernetes)

**Course:** Containerized Architecture  
**Author:** Leart Saliu ([@leartt0](https://github.com/leartt0)) — ls128837@seeu.edu.mk  
**Repository:** https://github.com/leartt0/Containerized-Architecture

Deploys the **[Adria Reserve](https://github.com/leartt0/adria-reserve)** travel booking platform on Kubernetes across **development**, **staging**, and **production** namespaces.

## Architecture Overview

| Component | K8s Object | Purpose |
| --------- | ---------- | ------- |
| React frontend (Nginx) | Deployment + Service | User-facing web UI |
| Express API backend | Deployment + Service | REST API, Bros Travel integration |
| PostgreSQL | StatefulSet + Headless Service | Persistent relational data |
| Health probe | Pod | Standalone pod demonstrating Pod resource |
| Secrets / ConfigMaps | Secret, ConfigMap | Credentials and non-sensitive config |
| Storage | PVC + StatefulSet volumeClaimTemplates | DB data and backend logs |
| Autoscaling | HPA (staging/prod), VPA recommendation mode | CPU/memory scaling |

## Environments

| Environment | Namespace | Replicas | Quota | HPA | VPA | DB Image |
| ----------- | ----------- | -------- | ----- | --- | --- | -------- |
| Development | `adria-dev` | 1 each | 1 CPU | No | No | postgres:14-alpine |
| Staging | `adria-staging` | 3 each | 2 CPU | Yes | Yes (Off) | postgres:15-alpine |
| Production | `adria-production` | 3+ each | None | Yes | Yes (Off) | postgres:15-alpine |

## Prerequisites

- [Minikube](https://minikube.sigs.k8s.io/docs/start/) or any Kubernetes cluster
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Docker](https://www.docker.com/)
- Adria Reserve source (sibling folder `adria-reserve-2` or set `ADRIA_RESERVE_PATH`)

## Quick Start (Minikube)

```bash
# 1. Clone both repositories
git clone https://github.com/leartt0/Containerized-Architecture.git
git clone https://github.com/leartt0/adria-reserve.git adria-reserve-2

# 2. Start Minikube and enable metrics-server
chmod +x scripts/*.sh
./scripts/setup-minikube.sh

# 3. Build images inside Minikube Docker daemon
eval $(minikube docker-env)
./scripts/build-images.sh

# 4. Deploy all environments
./scripts/deploy-all.sh

# 5. Open the app
minikube service adria-frontend -n adria-dev --url
```

## Docker Hub Images

Push images for professor/remote cluster testing:

```bash
docker login
./scripts/build-images.sh --push
```

| Image | Tags |
| ----- | ---- |
| `leartt0/adria-reserve-backend` | `1.0.0`, `1.0.0-dev`, `latest` |
| `leartt0/adria-reserve-frontend` | `1.0.0`, `1.0.0-dev`, `latest` |

## VPA (Vertical Pod Autoscaler)

VPA runs in **recommendation mode** (`updateMode: Off`). Install the VPA controller once per cluster:

```bash
kubectl apply -f https://github.com/kubernetes/autoscaler/releases/latest/download/vertical-pod-autoscaler.yaml
```

View recommendations:

```bash
kubectl describe vpa adria-backend-vpa -n adria-staging
```

## Verify Deployment

```bash
kubectl get pods,svc,deploy,statefulset,hpa,vpa,pvc,resourcequota -n adria-dev
kubectl get pods,svc,deploy,statefulset,hpa,vpa -n adria-staging
kubectl get pods,svc,deploy,statefulset,hpa,vpa -n adria-production

# Backend health
kubectl port-forward svc/adria-backend 3001:3001 -n adria-dev
curl http://localhost:3001/health
```

## Project Structure

```
Containerized-Architecture/
├── docker/
│   ├── backend/Dockerfile
│   └── frontend/Dockerfile + nginx.conf
├── k8s/
│   ├── namespaces/          # dev, staging, production
│   ├── dev/all.yaml         # 1 replica, quota 1 CPU, Pod example, no HPA
│   ├── staging/all.yaml     # 3 replicas, HPA, VPA, quota 2 CPU
│   └── production/all.yaml  # 3 replicas, HPA, VPA, no quota
├── scripts/
│   ├── prepare-app.sh
│   ├── build-images.sh
│   ├── setup-minikube.sh
│   └── deploy-all.sh
└── docs/
    └── ARCHITECTURE_SUMMARY.md
```

## Documentation

Full two-page architecture summary and diagram: **[docs/ARCHITECTURE_SUMMARY.md](docs/ARCHITECTURE_SUMMARY.md)**

## Design Decisions

- **StatefulSet for PostgreSQL** — stable network identity, ordered storage via `volumeClaimTemplates`
- **Deployments for stateless tiers** — frontend and backend scale horizontally
- **Headless Service for Postgres** — DNS records per pod (`adria-postgres-0.adria-postgres`)
- **Namespaces** — hard isolation of secrets, quotas, and configs per environment
- **ConfigMaps + Secrets** — non-sensitive vs sensitive configuration separation
- **NodePort Services** — easy Minikube access without Ingress controller setup
- **Init container** — backend waits for PostgreSQL before starting

## Presentation Notes

Be prepared to explain: why StatefulSet for DB, why 3 replicas in staging/prod, quota math (dev 1 CPU → staging 2 CPU → prod unlimited), HPA metrics, and VPA recommendation mode vs auto mode.

## License

**Live demo:** [demo.adriatours-ks.com](https://demo.adriatours-ks.com)

Licensed to **ADRIA TOURS SHPK**. Developed by **xbranding L.L.C**.

All rights reserved. Unauthorized copying, modification, or distribution without written permission from the license holder is prohibited.
