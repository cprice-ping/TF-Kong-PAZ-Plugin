# This is where you define things you want Kong to do
_format_version: "3.0"
_transform: true

# Define the Services \ Routes that you want to have managed with Kong
services:
  - name: media-metadata-api
    url: https://c8abe80f-f43b-4232-91cb-70cc024e39eb.mock.pstmn.io
    routes:
      - name: media-metadata-route
        paths:
          - /media
        strip_path: false

# Configuration of the `ping-auth` plugin - this can be PingAuthorize or PingOneAuthorize
plugins:
- name: ping-auth
  enabled: true
  config:
    # Ping Authorize
    service_url: ${serviceUrl}
    secret_header_name: CLIENT-TOKEN
    shared_secret: ${pluginSharedSecret}
    # PingOne Authorize
    # service_url: {{ .p1azServiceUrl }}
    # secret_header_name: CLIENT-TOKEN
    # shared_secret: {{ .pluginGatewayCredential }}