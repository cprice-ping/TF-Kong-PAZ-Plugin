# TF-Kong-PAZ-Plugin
 
Terraform that deploys a Kong Gateway with Ping(One) Authorize integration.

Helm is used to deploy a custom image of Kong that contains the Ping-Auth plugin, along with PingAuthorize and PingAuthorizePAP. PingOne Authorize is also implemented and can be used interchangeably with the Kong plug-in. Switching is done via the values passed into the `kong-declarative-config` ConfigMap.

P1 Console SSO into PingAuthorizePAP is included - the App is installed into the Administrators Environment. 

An OIDC Token App is also deployed to provide tokens used to access the Media API through Kong that is protected by the Ping-Auth plug-in.
