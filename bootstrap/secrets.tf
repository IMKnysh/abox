resource "kubectl_manifest" "ai_api_keys" {
    depends_on = [kind_cluster.this]

    yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: ai-providers-api-keys
  annotations:
    replicator.v1.mittwald.de/replicate-to: "kagent, agentgateway-system"
data:
  GOOGLE_API_KEY: "${base64encode(var.GOOGLE_API_KEY)}"
  OPENAI_API_KEY: "${base64encode(var.OPENAI_API_KEY)}"
  BEDROCK_API_KEY: "${base64encode(var.BEDROCK_API_KEY)}"
YAML
}