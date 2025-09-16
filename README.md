# Ailevate Snappass Service
Snappass is a secure, ephemeral password and secret sharing service, hosted and managed entirely by Ailevate. It allows employees to safely transmit secrets (e.g., API tokens, credentials) using one-time links, preventing sensitive data from being exposed in email or chat logs.

## 📌 Overview
This project deploys a private, production-ready instance of Pinterest's Snappass. The deployment is fully automated using Infrastructure as Code (Terraform) and a CI/CD pipeline (Azure DevOps).

* ✅ **Secure**: Secrets expire after the first view or a configurable time-to-live (TTL).
* ✅ **Auditable**: All significant events are logged to a central Log Analytics workspace for security monitoring.
* ✅ **Automated**: Infrastructure is version-controlled and deployed automatically, ensuring consistency and reliability.

---
## 🏛️ Architecture
The solution is deployed to Azure and consists of the following key components:
* **Azure App Service**: Runs the official `pinterest/snappass` Docker container on a Linux App Service Plan.
* **Azure Cache for Redis**: Provides a secure, ephemeral backend for storing secret data. It is secured via a **Private Endpoint** inside the VNet.
* **Azure Key Vault**: Securely stores and manages all application secrets, such as the Redis access key and the application's secret key. The App Service accesses these secrets securely using its Managed Identity.
* **Azure Virtual Network (VNet)**: Isolates all application components. The App Service is integrated into a subnet for secure internal communication.
* **Azure DNS**: Manages the custom domains (e.g., `snappass.eng.ailevate.com` and `www.snappass.eng.ailevate.com`) and the managed TLS certificates.
* **Azure Log Analytics**: A central workspace that collects diagnostic logs and metrics from all resources for monitoring and auditing.



---
## 🚀 Deployment
The entire infrastructure is deployed using the Azure DevOps pipeline defined in this repository.

### Prerequisites
* An Azure subscription with permissions to create the resources defined in the architecture.
* An Azure DevOps project with the required service connections configured.
* An Azure DNS Zone for `ailevate.com`.

### Pipeline Variables
Before running the pipeline, you must create a **Variable Group** in your Azure DevOps project's Library and link it to the `snappass` pipeline. It should contain the following variables:

| Variable Name | Description | Sample Value |
| --- | --- | --- |
| `AZURE_PROJECT_LE` | The logical environment name, used for tagging. | `internal` |
| `AZURE_PROJECT_NAME` | A short, unique name for the project (used for naming resources). | `snappass` |
| `AZURE_RG_LOCATION` | The Azure region where resources will be deployed. | `eastus2` |
| `AZURE_RG_NAME` | The name of the resource group for the application. | `rg-snappass-prod-eus2` |
| `AZURE_SERVICE_SPN` | The name of the Azure DevOps Service Connection for deploying resources. | `azdo-svc-prod` |
| `REPO_MANIFEST_FOLDER` | The path to the Terraform manifests within the repository. | `resource` |
| `SNAPPASS_SUBDOMAIN` | The base subdomain for the service (e.g., `snappass.eng`). | `snappass.eng` |
| `TAG_REQUIRED_CUSTOMER` | Tag value for identifying the business owner. | `Ailevate` |
| `TAG_REQUIRED_WORKLOADTIER` | Tag value for identifying the service criticality. | `business-critical` |
| `TERRAFORM_BACKEND_CONTAINER` | The Azure Storage container name for the Terraform state file. | `tfstate` |
| `TERRAFORM_BACKEND_RG` | The resource group name of the Terraform backend storage account. | `rg-internal-tfstate` |
| `TERRAFORM_BACKEND_SA` | The name of the Terraform backend storage account. | `stinternalterraform` |
| `TERRAFORM_BACKEND_SPN` | The ADO Service Connection for accessing the Terraform backend. | `azdo-svc-tfstate` |
| `VNET_ADDRESS_SPACE` | The address space for the virtual network. | `10.55.0.0/24` |
| `VNET_SUBNET_PREFIX` | The address prefix for the application's subnet. | `10.55.0.0/25` |
| `VNET_PE_SUBNET_PREFIX` | The address prefix for the private endpoint subnet. | `10.55.0.128/25` |

---
## 🔒 Security
* **Encryption**: All traffic is encrypted in transit using TLS 1.2. Data is encrypted at rest in Azure Cache for Redis and Azure Key Vault.
* **Secret Management**: No secrets are stored in code or pipeline variables. They are generated on first deployment and stored in Azure Key Vault. The App Service uses its Managed Identity to securely access secrets at runtime.
* **Network Isolation**: All components are isolated within a VNet. The Redis cache is only accessible via a private endpoint from within the VNet.
