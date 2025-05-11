# Output variables for the ArgoCD deployment
output "argocd_namespace" {
  description = "The namespace where ArgoCD is deployed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_deployment_name" {
  description = "The name of the ArgoCD server deployment"
  value       = kubernetes_deployment.argocd_server.metadata[0].name
}

output "argocd_service_name" {
  description = "The name of the ArgoCD service"
  value       = kubernetes_service.argocd_server.metadata[0].name
}

output "argocd_service_node_port" {
  description = "NodePort to access ArgoCD"
  value       = kubernetes_service.argocd_server.spec[0].port[0].node_port
}

output "argocd_ingress_host" {
  description = "The hostname for ArgoCD ingress"
  value       = kubernetes_ingress.argocd_server.spec[0].rule[0].host
}

# Output variables for the myapp deployment
output "myapp_namespace" {
  description = "The namespace where myapp is deployed"
  value       = kubernetes_namespace.default_ns.metadata[0].name
}

output "myapp_deployment_name" {
  description = "The name of the myapp deployment"
  value       = kubernetes_deployment.myapp.metadata[0].name
}

output "myapp_service_name" {
  description = "The name of the myapp service"
  value       = kubernetes_service.myapp_service.metadata[0].name
}

output "myapp_service_node_port" {
  description = "NodePort to access myapp"
  value       = kubernetes_service.myapp_service.spec[0].port[0].node_port
}

output "myapp_ingress_host" {
  description = "The hostname for myapp ingress"
  value       = kubernetes_ingress.myapp_ingress.spec[0].rule[0].host
}

# ArgoCD Application tracking outputs
output "argocd_application_name" {
  description = "The ArgoCD application name"
  value       = kubernetes_manifest.argocd_application_myapp.manifest.metadata.name
}

output "argocd_repo_url" {
  description = "The repository URL tracked by ArgoCD"
  value       = kubernetes_manifest.argocd_application_myapp.manifest.spec.source.repoURL
}

output "argocd_sync_policy" {
  description = "ArgoCD sync policy settings"
  value       = kubernetes_manifest.argocd_application_myapp.manifest.spec.syncPolicy.automated
}
