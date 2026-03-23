# ==============================================================================
# SECRETS needed for GitHub Actions Environment Configuration
# COPY AND PASTE THESE VALUES SECURELY INTO YOUR GITHUB REPOSITORY SECRETS!
# ==============================================================================

output "AZURE_CLIENT_ID" {
  description = "Application (Client) ID of the Azure AD Identity for GitHub OIDC."
  value       = azuread_application.github_actions_oidc.client_id
}

output "AZURE_TENANT_ID" {
  description = "Tenant ID bounding the Azure AD Identity."
  value       = data.azurerm_client_config.current.tenant_id
}

output "AZURE_SUBSCRIPTION_ID" {
  description = "The active Azure Subscription ID mapped to the pipeline."
  value       = data.azurerm_client_config.current.subscription_id
}
