# -------------------------------------------------------------
# OIDC / GitHub Actions Identity Variables
# -------------------------------------------------------------
variable "tenant_id" {
  description = "Azure Active Directory Tenant ID"
  type        = string
}

variable "github_organization" {
  description = "GitHub Organization or Username"
  type        = string
  default     = "sonbarse17"
}

variable "github_repository" {
  description = "GitHub Repository Name"
  type        = string
  default     = "reusable-azure-deployment"
}
