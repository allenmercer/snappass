# Variables that should be set before deployment.

variable "vnet_address_space" {
  description = "VNET Address Space"
  default = "<-VNET_ADDRESS_SPACE->"
  type = string
}

variable "vnet_subnet_prefix" {
  description = "VNET Subnet Prefix"
  default = "<-VNET_SUBNET_PREFIX->"
  type = string
}

variable "vnet_pe_subnet_prefix" {
  description = "VNET Private Endpoint Subnet Prefix"
  default = "<-VNET_PE_SUBNET_PREFIX->"
  type = string
}

variable "rg_name" {
  description = "Resource Group Name"
  # This variable already exists in the pipeline as AZURE_RG_NAME.  It can be sent as a Terraform command line option.
  default = "<-AZURE_RG_NAME->"
  type = string
}

variable "location" {
  description = "Location"
  # This variable already exists in the pipeline as AZURE_RG_LOCATION.  It can be sent as a Terraform command line option.
  default = "<-AZURE_RG_LOCATION->"
  type = string
}

variable "environment" {
  description = "Environment"
  # This variable already exists in the pipeline as AZURE_PROJECT_LE.  It can be sent as a Terraform command line option.
  default = "<-AZURE_PROJECT_LE->"
  type = string
}

variable "project_name" {
  description = "Project Name"
  # This variable already exists in the pipeline as AZURE_PROJECT_NAME.  It can be sent as a Terraform command line option.
  default = "<-AZURE_PROJECT_NAME->"
  type = string
}

variable "snappass_subdomain" {
  description = "WordPress Subdomain"
  # This variable already exists in the pipeline as AZURE_PROJECT_NAME.  It can be sent as a Terraform command line option.
  default = "<-SNAPPASS_SUBDOMAIN->"
  type = string
}

variable "workloadtier" {
  description = "Workload Tier"
  # This variable already exists in the pipeline as TAG_REQUIRED_WORKLOADTIER.  It can be sent as a Terraform command line option.
  default = "<-TAG_REQUIRED_WORKLOADTIER->"
  type = string
}

variable "customer" {
  description = "Customer"
  # This variable already exists in the pipeline as TAG_REQUIRED_CUSTOMER.  It can be sent as a Terraform command line option.
  default = "<-TAG_REQUIRED_CUSTOMER->"
  type = string
}


# Locals Block

locals {
  tags = {
    creator = "terraform"
    workloadtier = var.workloadtier
    customer = var.customer
    environment = var.environment
    workload = var.project_name
  }
}