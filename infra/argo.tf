# File: infra/argo.tf
# Description: Terraform configuration to deploy ArgoCD on a Kubernetes cluster.

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
          image = "docker.io/argoproj/argocd:latest"

          # Enhanced resource limits to prevent API throttling and optimize performance
          resources {
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "750m"
              memory = "768Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 443
            }
            initial_delay_seconds = 20
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = 443
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }

          port {
            container_port = 443
          }
        }
      }
    }
  }

  timeouts {
    create = "10m" # Extended timeout to avoid rate limiter issues
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
      app = "argocd-server"
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

