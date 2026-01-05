resource "kubernetes_manifest" "datadog_agent" {
  manifest = yamldecode(file("${path.module}/k8s/datadog-agent.yaml"))
}

resource "kubernetes_manifest" "web_secret" {
  manifest = yamldecode(file("${path.module}/k8s/web-secret.yaml"))
}

resource "kubernetes_manifest" "db_secret" {
  manifest = yamldecode(file("${path.module}/k8s/db-secret.yaml"))
}

resource "kubernetes_manifest" "web_config" {
  manifest = yamldecode(file("${path.module}/k8s/app-config.yaml"))
}

resource "kubernetes_manifest" "db_deployment" {
  manifest = yamldecode(file("${path.module}/k8s/db-deployment.yaml"))
  depends_on = [ kubernetes_manifest.db_secret ]
}

resource "kubernetes_manifest" "db_service" {
  manifest = yamldecode(file("${path.module}/k8s/db-service.yaml"))
  depends_on = [ kubernetes_manifest.db_deployment ]
}

resource "kubernetes_manifest" "web_deployment" {
  manifest = yamldecode(file("${path.module}/k8s/web-deployment.yaml"))
  depends_on = [
    kubernetes_manifest.datadog_agent,
    kubernetes_manifest.web_secret,
    kubernetes_manifest.web_config,
    kubernetes_manifest.db_service
  ]
}

resource "kubernetes_manifest" "web_service" {
  manifest = yamldecode(file("${path.module}/k8s/web-service.yaml"))
  depends_on = [
    kubernetes_manifest.web_deployment
  ]
}

resource "kubernetes_manifest" "web_hpa" {
  manifest = yamldecode(file("${path.module}/k8s/web-hpa.yaml"))
  depends_on = [
    kubernetes_manifest.web_deployment,
    kubernetes_manifest.web_service
  ]

  lifecycle {
    ignore_changes = [
      object.spec.behavior.scaleUp.selectPolicy,
      object.spec.behavior.scaleDown.selectPolicy
    ]
  }
}
