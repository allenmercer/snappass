# Ailevate Echo Service
Ailevate Echo is a secure, ephemeral secret sharing service, hosted and managed entirely by Ailevate. It allows employees to safely transmit secrets (e.g., API tokens, credentials) using one-time links, preventing sensitive data from being exposed in email or chat logs.

## 📌 Overview
This project deploys a private, production-ready instance of Ailevate Echo. The deployment is fully automated using Infrastructure as Code (Terraform) and a CI/CD pipeline (Azure DevOps) that builds a custom, Ailevate-branded version of the underlying Snappass application.

* ✅ **Secure**: Secrets expire after the first view or a configurable time-to-live (TTL).
* ✅ **Auditable**: All significant events are logged to a central Log Analytics workspace for security monitoring.
* ✅ **Automated**: Infrastructure is version-controlled and deployed automatically, ensuring consistency and reliability.

---
## 🏛️ Architecture
The solution is deployed to Azure and consists of the following key components:
* **Azure Container Registry**: Stores the custom-built, Ailevate-branded Docker image for the application.
* **Azure App Service**: Runs the custom Docker container on a Linux App Service Plan.
* **Azure Cache for Redis**: Provides a secure, ephemeral backend for storing secret data, secured via a **Private Endpoint**.
* **Azure Key Vault**: Securely stores and manages all application secrets.
* **Azure Virtual Network (VNet)**: Isolates all application components.
* **Azure DNS**: Manages the custom domains (e.g., `echo.eng.ailevate.com`) and the managed TLS certificates.
* **Azure Log Analytics**: A central workspace that collects diagnostic logs and metrics.

---
## 🚀 Deployment
The entire infrastructure is deployed using the Azure DevOps pipeline defined in this repository.

### Prerequisites
* An Azure subscription with permissions to create the resources.
* An Azure DevOps project with the required service connections.
* An Azure DNS Zone for `ailevate.com`.
* An Azure Container Registry named `ailevate.azurecr.io`.

### Pipeline Variables
Before running the pipeline, create a **Variable Group** in your Azure DevOps project's Library with the following variables:

| Variable Name | Description | Sample Value |
| --- | --- | --- |
| `ACR_SERVICE_CONNECTION` | The ADO Service Connection for the Docker Registry. | `AilevateACRServiceConnection` |
| `AZURE_PROJECT_LE` | The logical environment name for tagging. | `internal` |
| `AZURE_PROJECT_NAME` | A short name for the project (used for resource naming). | `echo` |
| `AZURE_RG_LOCATION` | The Azure region for deployment. | `eastus2` |
| `AZURE_RG_NAME` | The name of the application resource group. | `rg-echo-prod-eus2` |
| `AZURE_SERVICE_SPN` | The ADO Service Connection for deploying resources. | `azdo-svc-prod` |
| `NEW_APP_DESCRIPTION` | The branded text displayed on the main page. | `Ailevate Echo allows you to securely share information.` |
| `REPO_MANIFEST_FOLDER` | The path to the Terraform manifests. | `resource` |
| `SNAPPASS_SUBDOMAIN` | The base subdomain for the service. | `echo.eng` |
| `TAG_REQUIRED_CUSTOMER` | Tag value for the business owner. | `Ailevate` |
| `TAG_REQUIRED_WORKLOADTIER` | Tag value for service criticality. | `business-critical` |
| `TERRAFORM_BACKEND_CONTAINER` | The Azure Storage container for the Terraform state file. | `tfstate` |
| `TERRAFORM_BACKEND_RG` | The RG of the Terraform backend storage account. | `rg-internal-tfstate` |
| `TERRAFORM_BACKEND_SA` | The Terraform backend storage account name. | `stinternalterraform` |
| `TERRAFORM_BACKEND_SPN` | The ADO Service Connection for the Terraform backend. | `azdo-svc-tfstate` |
| `VNET_ADDRESS_SPACE` | The address space for the virtual network. | `10.55.0.0/24` |
| `VNET_SUBNET_PREFIX` | The address prefix for the application's subnet. | `10.55.0.0/25` |
| `VNET_PE_SUBNET_PREFIX` | The address prefix for the private endpoint subnet. | `10.55.0.128/25` |

---
## 🔒 Security
* **Encryption**: All traffic is encrypted in transit using TLS 1.2. Data is encrypted at rest in Azure Cache for Redis and Azure Key Vault.
* **Secret Management**: No secrets are stored in code or pipeline variables. They are generated on first deployment and stored in Azure Key Vault. The App Service uses its Managed Identity to securely access secrets at runtime.
* **Network Isolation**: All components are isolated within a VNet. The Redis cache is only accessible via a private endpoint from within the VNet.