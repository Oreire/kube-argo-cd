# File: infra/argo.tf
# Description: This Terraform configuration deploys ArgoCD on a Kubernetes cluster.
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_deployment" "argocd_server" {
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
          image = "argoproj/argocd:v2.9.3"

          port {
            container_port = 443
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  spec {
    selector = {
      app = "argocd-server"
    }

    type = "NodePort"

    port {
      port        = 443
      target_port = 443   # Simplified direct reference
      node_port   = 30443 # Accessible via http://localhost:30443
    }
  }
}

resource "kubernetes_ingress" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
  spec {
    rule {
      host = "argocd.local"
      http {
        path {
          path = "/"
          # path_type removed as it is not supported in the current provider version
          backend {
            service_name = kubernetes_service.argocd_server.metadata[0].name
            service_port = 443
          }
        }
      }
    }
  }
}