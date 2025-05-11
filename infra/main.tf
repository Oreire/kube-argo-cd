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
      node_port   = 31444 # Accessible via http://localhost:31444
    }
  }
}

