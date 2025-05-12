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
      node_port   = 31555 # Accessible via http://localhost:31444
    }
  }
}

# Automate Port Forwarding after Service Creation
resource "null_resource" "port_forward_myapp" {
  depends_on = [kubernetes_service.myapp_service] # Ensures service exists first

  provisioner "local-exec" {
    # Port forward to the myapp service
    command = "powershell -Command 'kubectl port-forward svc/myapp-service 8081:80 -n default &'"
  }

  triggers = {
    always_run = timestamp()
  }
}


