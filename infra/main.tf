provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment" "myapp" {
  metadata {
    name      = "myapp"
    namespace = "default"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "myapp"
      }
    }
    template {
      metadata {
        labels = {
          app = "myapp"
        }
      }
      spec {
        container {
          name  = "app"
          image = "ghs-nginx-app42"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "myapp_service" {
  metadata {
    name      = "myapp-service"
    namespace = "default"
  }

  spec {
    selector = {
      app = "myapp"
    }

    type = "NodePort"

    port {
      port        = 80
      target_port = 80
      node_port   = 30080 # Accessible via http://localhost:30080
    }
  }
}

resource "kubernetes_manifest" "argocd_application_myapp" {
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
