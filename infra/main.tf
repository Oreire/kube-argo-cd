provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment" "myapp" {
  metadata {
    name = "myapp"
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
          image = "nginx"
        }
      }
    }
  }
}