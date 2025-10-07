# Ailevate Secret Sharing Service
Ailevate Secret Sharing Service is a secure, ephemeral secret sharing service, hosted and managed entirely by Ailevate. It allows employees and customers to safely transmit secrets (e.g., API tokens, credentials) using one-time links, preventing sensitive data from being exposed in email or chat logs.

## 📌 Overview
This project deploys a private, production-ready instance of Ailevate Secret Sharing Service. The deployment is fully automated using Infrastructure as Code (Terraform) and a CI/CD pipeline (Azure DevOps) that builds a custom, Ailevate-branded version of the underlying Snappass application.

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
* **Azure DNS**: Manages the custom domains (e.g., `secret.ailevate.com`) and the managed TLS certificates.
* **Azure Log Analytics**: A central workspace that collects diagnostic logs and metrics.

![Architecture Diagram](img/secret-share-architecture.png)

---
## 📖 How to Use the Service
Using the Ailevate Secret Sharing Service is a simple, secure process.

#### 1. Set Your Secret
Navigate to the service URL: **[https://secret.ailevate.com](https://secret.ailevate.com)**. Enter the secret you wish to share into the text box, select an expiration time, and click "Generate Secure Link".

![Set a secret](img/set-secret.png)

#### 2. Share the Secure Link
The application will generate a unique, one-time use link. Copy this link and send it to your intended recipient.

![Share the secret link](img/share-secret.png)

#### 3. Recipient Previews the Secret
When the recipient clicks the link, they are first shown a confirmation page. This is a final warning that the secret can only be viewed once and will be permanently destroyed after viewing.

![Preview the secret](img/preview-secret.png)

#### 4. Secret is Revealed
After clicking "View Secret Now," the recipient is shown the secret. At this moment, the link is invalidated, and the data is permanently deleted from the server.

![Reveal the secret](img/reveal-secret.png)

#### 5. Link is Destroyed
If anyone (including the original recipient) tries to visit the link again, they will see a confirmation that the secret has been destroyed and can no longer be accessed.

![Expired secret](img/expired-secret.png)

---
## 🤖 API Usage
The Ailevate Secret Sharing Service has 2 APIs:
1.  A **Simple API** that can be used to create secret links and then share them with users.
2.  A more **REST-y API** which facilitates programmatic interactions without having to parse HTML content.

### Simple API
The advantage of using the simple API is that you can create a secret and retrieve the link without having to open the web interface. This is useful for embedding in simple scripts.

To create a secret, send a POST request to `/` like so:
```bash
curl -X POST \
  --data-urlencode "secret=My top secret value" \
  --data "ttl=3600" \
  [https://secret.ailevate.com](https://secret.ailevate.com)```


