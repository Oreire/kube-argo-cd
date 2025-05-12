# kube-argo-cd

#Deploying Containerized Web Applications on Kubernetes Infrastructure Using GitOps- An ArgoCD Implementation Using GitHub Actions


Tesing Self Hosted Runner
Git upgrade
powershell installed
Resources manually deleted



provisioner "local-exec" {
  command = "powershell -Command 'kubectl port-forward svc/myapp-service 8081:80 -n default &'"
}
