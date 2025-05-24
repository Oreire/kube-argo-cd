resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd-2025"
  }
}

resource "kubernetes_deployment" "argocd_server" {
  depends_on = [kubernetes_namespace.argocd]

  metadata {
    name      = "argocd-server-2"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "argocd-server-2"
      }
    }
    template {
      metadata {
        labels = {
          app = "argocd-server-2"
        }
      }
      spec {
        container {
          name              = "argocd-server-2"
          image             = "docker.io/docker-hardened/argocd:latest" # Replace with the desired image
          image_pull_policy = "IfNotPresent"

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
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          port {
            container_port = 8080
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
    name      = "argocd-service-2025"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  spec {
    selector = {
      app = "argocd-server-2"
    }

    type = "NodePort"

    port {
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
      name        = "http"
      node_port   = 30444 # Accessible via http://localhost:30444
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
      namespace = "argocd-2025"
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
