# File: infra/argo.tf
# Description: This Terraform configuration deploys ArgoCD on a Kubernetes cluster.

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_deployment" "argocd_server" {
  depends_on = [kubernetes_namespace.argocd]

  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "argocd-server"
      }
    }
    template {
      metadata {
        labels = {
          app = "argocd-server"
        }
      }
      spec {
        container {
          name  = "argocd-server"
          image = "custom-argocd1" # Corrected image reference

          resources {
            requests = {
              cpu    = "500m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 443
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = 443
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }

          port {
            container_port = 443
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "argocd_service" {
  depends_on = [kubernetes_deployment.argocd_server]

  metadata {
    name      = "argocd-service"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  spec {
    selector = {
      app = "argocd-server" # Fixed label selector to match the deployment
    }

    type = "NodePort"

    port {
      port        = 443
      target_port = 443
      node_port   = 30443 # Accessible via http://localhost:30443
    }
  }
}


resource "kubernetes_manifest" "argocd_application_myapp" {
  depends_on = [kubernetes_service.argocd_service]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "myapp"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/Oreire/kube-argo-cd.git"
        path           = "infra"
        targetRevision = "main"
      }
      destination = {
        namespace = "default"
        server    = "https://kubernetes.default.svc"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
}
