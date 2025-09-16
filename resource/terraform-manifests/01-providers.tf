## Terraform Settings Block
terraform {

  required_version = ">=1.10.4"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.33.0"
    }
  }

  backend "azurerm" {
    # The below values will be provided in the "terraform init" command.
    # resource_group_name = ""
    # storage_account_name = ""
    # container_name = ""
    # key = ""
  }
}


## Provider Blocks
provider "azurerm" {
  # The below values are unnecessary because of the "az login" in the pipeline.
  # subscription_id     = ""
  # client_id           = ""
  # client_secret       = ""
  # tenant_id           = ""
  features {
    # Let 'terraform destroy' purge soft-deleted KV so disposables tear down cleanly.
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "4ae1ac6d-b9f0-4d08-8593-4c282ded34aa"
  alias = "dev_monitoring"
}

provider "azurerm" {
  features {}
  subscription_id = "aabf3535-ee68-4e6c-9fca-8d80aa252fbf"
  alias = "sre_dns"
}
