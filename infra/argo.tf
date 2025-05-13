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
          image = "argoproj/argocd:v2.10.0"

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
            initial_delay_seconds = 10
            period_seconds        = 5
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = 443
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          port {
            container_port = 443
          }
        }
      }
    }
  }

  timeouts {
    create = "10m"
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
      node_port   = 30443
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