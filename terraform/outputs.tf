output "pap_logon" {
  value = "https://${data.kubernetes_ingress_v1.pap_ingress.spec.0.rule.0.host}"
}

output "kong_tokens" {
  value = "https://auth.pingone.${local.pingone_domain}/${pingone_environment.kong_token_provider.id}/as/authorize?client_id=${pingone_application.kong_tokens.id}&scope=openid email profile&response_type=code&redirect_uri=https://decoder.pingidentity.cloud/oidc"
}

output "kong_url" {
  value = "https://${kubernetes_ingress_v1.kong_ingress.spec.0.rule.0.host}"
}
