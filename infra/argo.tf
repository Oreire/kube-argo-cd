resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_manifest" "argocd_install" {
  manifest = [
    {
      apiVersion = "v1"
      kind       = "Namespace"
      metadata = {
        name = "argocd"
      }
    },
    {
      apiVersion = "apps/v1"
      kind       = "Deployment"
      metadata = {
        name      = "argocd-server"
        namespace = "argocd"
      }
      spec = {
        replicas = 1
        selector = {
          matchLabels = {
            app = "argocd-server"
          }
        }
        template = {
          metadata = {
            labels = {
              app = "argocd-server"
            }
          }
          spec = {
            containers = [
              {
                name  = "argocd-server"
                image = "argoproj/argocd:v2.9.0"
                ports = [
                  {
                    containerPort = 443
                  }
                ]
              }
            ]
          }
        }
      }
    }
  ]
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

    port {
      port        = 443
      target_port = 443
    }
  }
}