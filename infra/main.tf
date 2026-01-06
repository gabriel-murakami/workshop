resource "kubectl_manifest" "datadog_agent" {
  yaml_body = file("${path.module}/k8s/datadog-agent.yaml")
}

resource "kubectl_manifest" "web_secret" {
  yaml_body = file("${path.module}/k8s/web-secret.yaml")
}

resource "kubectl_manifest" "db_secret" {
  yaml_body = file("${path.module}/k8s/db-secret.yaml")
}

resource "kubectl_manifest" "web_config" {
  yaml_body = file("${path.module}/k8s/app-config.yaml")
}

resource "kubectl_manifest" "db_deployment" {
  yaml_body  = file("${path.module}/k8s/db-deployment.yaml")
  depends_on = [kubectl_manifest.db_secret]
}

resource "kubectl_manifest" "db_service" {
  yaml_body  = file("${path.module}/k8s/db-service.yaml")
  depends_on = [kubectl_manifest.db_deployment]
}

resource "kubectl_manifest" "web_deployment" {
  yaml_body = file("${path.module}/k8s/web-deployment.yaml")
  depends_on = [
    kubectl_manifest.datadog_agent,
    kubectl_manifest.web_secret,
    kubectl_manifest.web_config,
    kubectl_manifest.db_service
  ]
}

resource "kubectl_manifest" "web_service" {
  yaml_body  = file("${path.module}/k8s/web-service.yaml")
  depends_on = [kubectl_manifest.web_deployment]
}

resource "kubectl_manifest" "web_hpa" {
  yaml_body = file("${path.module}/k8s/web-hpa.yaml")
  depends_on = [
    kubectl_manifest.web_deployment,
    kubectl_manifest.web_service
  ]
}
