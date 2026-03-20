variable "subscription_id" {
  description = "Azure Subscription ID to deploy resources into"
  type        = string
}

variable "resource_group_name" {
  description = "Base name for the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
}

variable "environment" {
  description = "Environment tag (dev, uat, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Environment must be one of: dev, uat, prod."
  }
}

variable "project_name" {
  description = "Short project identifier used in resource naming"
  type        = string
}

variable "webapp_sku" {
  description = "SKU for the Web App Service Plan (e.g., B1, B2, S1, P1v3)"
  type        = string
  default     = "B1"
}

variable "function_sku" {
  description = "SKU for the Function App Service Plan (Y1 = Consumption, EP1 = Premium)"
  type        = string
  default     = "Y1"
}

variable "node_version" {
  description = "Node.js version for Web App and Node Function"
  type        = string
  default     = "20"
}

variable "python_version" {
  description = "Python version for Python Function"
  type        = string
  default     = "3.11"
}

variable "dotnet_version" {
  description = ".NET version for .NET Function"
  type        = string
  default     = "8.0"
}

variable "log_retention_days" {
  description = "Log Analytics workspace retention in days"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
