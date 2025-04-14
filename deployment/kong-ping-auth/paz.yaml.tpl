global:
  addReleaseNameToResource: prepend

  ingress:
    enabled: true
    addReleaseNameToHost: append
    defaultDomain: ping-devops.com
    annotations:
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
      kubernetes.io/ingress.class: "nginx-public"

pingauthorize:
  enabled: true
  envs:
    PING_IDENTITY_ACCEPT_EULA: "YES"
    DECISION_POINT_SHARED_SECRET: ${papSharedSecret}
    PLUGIN_SHARED_SECRET: ${pluginSharedSecret}
    SERVER_PROFILE_URL: https://github.com/cprice-ping/TF-Kong-PAZ-Plugin.git
    SERVER_PROFILE_PATH: deployment/pingauthorize

pingauthorizepap:
  enabled: true
  envs:
    PING_IDENTITY_ACCEPT_EULA: "YES"
    PING_EXTERNAL_BASE_URL: ${externalUrl}
    PING_OIDC_CONFIGURATION_ENDPOINT: ${oidcWellKnownEndpoint}
    PING_CLIENT_ID: ${clientId }
    PING_SCOPE: "openid email profile phone"
    SERVER_PROFILE_URL: https://github.com/cprice-ping/TF-Kong-PAZ-Plugin.git
    SERVER_PROFILE_PATH: deployment/pingauthorizepap
    