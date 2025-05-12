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





