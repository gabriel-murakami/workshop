resource "kubectl_manifest" "config" {
  yaml_body = file("${path.module}/../k8s/app-config.yaml")
}

resource "kubectl_manifest" "secret" {
  yaml_body = file("${path.module}/../k8s/web-secret.yaml")
}

resource "kubectl_manifest" "deployment" {
  yaml_body  = file("${path.module}/../k8s/order-service-deployment.yaml")
  depends_on = [kubectl_manifest.config, kubectl_manifest.secret]
}

resource "kubectl_manifest" "worker-deployment" {
  yaml_body  = file("${path.module}/../k8s/order-worker-deployment.yaml")
  depends_on = [kubectl_manifest.config, kubectl_manifest.secret]
}

resource "kubectl_manifest" "service" {
  yaml_body  = file("${path.module}/../k8s/web-service.yaml")
  depends_on = [kubectl_manifest.deployment]
}

resource "kubectl_manifest" "hpa" {
  yaml_body = file("${path.module}/../k8s/web-hpa.yaml")
}
