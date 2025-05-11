provider "kubernetes" {
  config_path = "~/.kube/config"
}

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
          image = "argoproj/argocd:v2.9.0"
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

    type = "NodePort"  # Updated for local access

    port {
      port        = 443
      target_port = kubernetes_deployment.argocd_server.spec[0].template[0].spec[0].container[0].port[0].container_port
      node_port   = 30443  # Accessible via http://localhost:30443
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
      host = "argocd.local"  # Updated for local access

      http {
        path {
          path      = "/"  

          backend {
            service_name = kubernetes_service.argocd_server.metadata[0].name
            service_port = kubernetes_service.argocd_server.spec[0].port[0].port
          }
        }
      }
    }
  }
}
