# ==========================================
# Step 1: Flux HelmRepository + HelmReleases
# (installs Gateway API CRDs + agentgateway)
# ==========================================
data "kubectl_file_documents" "helmreleases" {
  content = file("${path.module}/../gatewayapi/HelmReleases.yaml")
}

resource "kubectl_manifest" "helmreleases" {
  depends_on = [helm_release.flux_instance]
  for_each   = data.kubectl_file_documents.helmreleases.manifests

  yaml_body        = each.value
  wait             = true
  server_side_apply = true
}

# ==========================================
# Step 2: GatewayClass + Gateway
# (requires Gateway API CRDs from step 1)
# ==========================================
data "kubectl_file_documents" "gateway" {
  content = file("${path.module}/../gatewayapi/Gateway.yaml")
}

resource "kubectl_manifest" "gateway" {
  depends_on = [kubectl_manifest.helmreleases]
  for_each   = data.kubectl_file_documents.gateway.manifests

  yaml_body        = each.value
  server_side_apply = true
}
