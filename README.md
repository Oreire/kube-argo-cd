# kube-argo-cd

#Deploying Containerized Web Applications on Kubernetes Infrastructure Using GitOps- An ArgoCD Implementation Using GitHub Actions


Tesing Self Hosted Runner
Git upgrade
powershell installed
Resources manually deleted

docker inspect --format='{{index .RepoDigests 0}}' argoproj/argocd:latest
(to get image with digest)

name: Deploy ArgoCD & MyApp with Port Forwarding

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: [self-hosted, Windows, X64]  # Runs on your local machine

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Initialize, Validate & Format Terraform Configuration
        run: |
          cd infra
          terraform init
          terraform validate
          terraform fmt
          echo "Terraform configuration initialized, validated, and formatted."

      - name: Plan & Apply Terraform Changes
        run: |
          cd infra
          terraform plan -out=ArgoCD-Plan
          terraform apply -auto-approve
          echo "Terraform changes applied."

      - name: Verify Kubernetes Deployments
        run: |
          kubectl get pods -n argocd
          kubectl get services -n argocd
          kubectl get pods -n default
          kubectl get services -n default
          echo "Kubernetes resources verified."

      - name: Start Port Forwarding
        run: |
          nohup kubectl port-forward svc/argocd-server 8080:443 -n argocd &
          nohup kubectl port-forward svc/myapp-service 8081:80 -n default &
          sleep 10  # Allow forwarding to establish
          echo "Port forwarding setup for ArgoCD and MyApp."

      - name: Access Services
        run: |
          echo "Access ArgoCD UI at http://localhost:8080"
          echo "Access MyApp at http://localhost:8081"

      - name: Cleanup
        run: |
          pkill -f "kubectl port-forward"
          echo "Port forwarding processes cleaned up."


# ArgoCD Image
docker.io/argoproj/argocd:latest
image = "argoproj/argocd:v2.9.0"

Project
This project sets up a simple containerized app, ensuring it's tracked by ArgoCD.The Project uses terraform for the provisioning of the necessary infrastructure via the following steps:

## Step 1: 

## Define the Application Deployment**

## Define the Application Service**

## Define ArgoCD Deploymnet and Service

## Create the ArgoCD Application Manifest**
This tells **ArgoCD** to track and sync the app from a Git repository:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: "https://github.com/YourRepo/kubernetes-config.git"
    path: "deployments/myapp"
    targetRevision: "main"
  destination:
    namespace: default
    server: "https://kubernetes.default.svc"
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### **Applying the Configuration**
Save these files and apply them:
```bash
kubectl apply -f myapp-deployment.yaml
kubectl apply -f myapp-service.yaml
kubectl apply -f myapp-argocd.yaml
```
Then, verify the sync in ArgoCD:
```bash
kubectl get applications -n argocd
```

This setup ensures **ArgoCD tracks your app**, automates deployment updates, and maintains GitOps integrity. 🚀 Let me know if you need refinements!

updated manifest for argocd deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: argocd-server
  namespace: argocd
  labels:
    app: argocd-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: argocd-server
  template:
    metadata:
      labels:
        app: argocd-server
    spec:
      containers:
        - name: argocd-server
          image: bitnami/argo-cd@sha256:f71bd94f4930cb12dea1d8bf158a3dd1231d395bb9ece998dbda3e577f6e1c04
          ports:
            - containerPort: 443
          resources:
            requests:
              cpu: "250m"
              memory: "256Mi"
            limits:
              cpu: "750m"
              memory: "768Mi"