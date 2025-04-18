# TF-Kong-PAZ-Plugin

Terraform that deploys a Kong Gateway with Ping(One) Authorize integration.

Helm is used to deploy a custom image of Kong that contains the Ping-Auth plugin, along with PingAuthorize and PingAuthorizePAP. PingOne Authorize is also implemented and can be used interchangeably with the Kong plug-in. Switching is done via the values passed into the `kong-declarative-config` ConfigMap.

P1 Console SSO into PingAuthorizePAP is included - the App is installed into the Administrators Environment.

An OIDC Token App is also deployed to provide tokens used to access the Media API through Kong that is protected by the Ping-Auth plug-in.

## Sample `terraform.tfvars`

To inject your values into the terraform deployment, create a new `terraform.tfvars` file as follows:

```tfvars
# K8s Deployment
namespace    = "{{Namespace to deploy into}}"
deployName   = "{{Deployment name - also used for PingOne Env Name}}"
kongName     = "{Deployment name for Kong API Gateway}"
deployDomain = "{{Ingress Domain Name}}"

# PingOne Variables
regionCode     = "{{PingOne Region Code -- NA | EU | CA | AU | ASIA}}"
organizationId = "{{PingOne Org ID}}"
environmentId  = "{{PingOne Admin Env ID}}"
workerId       = "{{PingOne Worker ID -- needs Roles to create new Envs & Services}}"
workerSecret   = "{{PingOne Worker Secret}}"
licenseName    = "{{PingOne License name to put on new Env}}"
adminUserName  = "{{PingOne Admin Username -- should be in the Administrators Env}}"

# PAZ Variables
papSharedSecret    = "{{Shared secret used to connect to Policy Admin software}}"
pluginSharedSecret = "{{Shared secret used between Kong and PAZ}}"
```

## PingOne Authorize

PingOne Authorize - API Access Management receives a full configuration of:

* API Gateway (the deployed Kong instance)
  * API Gateway Credentials (applied to the Kong Gateway plugin via the `kong-declarative-config` ConfigMap)
* API Service (Mock Media API)
  * Operation config for `/media/metadata` and `/media/metadata/{mediaId}`
* API Service Reource
  * Audience (`https://{deployed Kong URL}`)
  * Scopes (`kong_get`, `kong_post`, `kong_delete`)
  * Permissions (`Metadata:Read_All`, `Metadata:Read_One`, `Account:manage_account`, `Account:manage_subscription`, `Account:manage_profile`)
  * Application Roles (`Primary`, `Profile`)
    > Users will need to be created and assigned to these Roles to get their permissions

This configuration should allow you to quickly demonstrate P1AZ AAM using the AAM Operations settings.
