# ==============================================================================
# Azure AD Application for GitHub Actions OIDC Authentication
# ==============================================================================

# Data source for current configuration
data "azurerm_client_config" "current" {}

# Create an Azure Active Directory Application
resource "azuread_application" "github_actions_oidc" {
  display_name = "github-actions-${var.project_name}-${var.environment}"
  owners       = [data.azurerm_client_config.current.object_id]
}

# Create a Service Principal for the Azure AD Application
resource "azuread_service_principal" "github_actions_oidc" {
  client_id                    = azuread_application.github_actions_oidc.client_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
}

# Assign the 'Contributor' role at the Resource Group boundary to the Service Principal
# This specifically limits what GitHub can mess with to strictly the project's infra!
resource "azurerm_role_assignment" "github_actions_rg" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_actions_oidc.object_id
}

resource "azurerm_role_assignment" "github_actions_rg_func" {
  scope                = azurerm_resource_group.rg_func.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_actions_oidc.object_id
}

# ==============================================================================
# Federated Identity Credentials Mapping (GitHub -> Azure)
# ==============================================================================

# Allow deployments to the target "dev" environment configured in GitHub
resource "azuread_application_federated_identity_credential" "github_env_dev" {
  application_id = azuread_application.github_actions_oidc.id
  display_name   = "github-actions-dev"
  description    = "Deployments for GitHub Environment: dev"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_organization}/${var.github_repository}:environment:dev"
}

# Allow deployments to the target "uat" environment configured in GitHub
resource "azuread_application_federated_identity_credential" "github_env_uat" {
  application_id = azuread_application.github_actions_oidc.id
  display_name   = "github-actions-uat"
  description    = "Deployments for GitHub Environment: uat"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_organization}/${var.github_repository}:environment:uat"
}

# Allow deployments to the target "prod" environment configured in GitHub
resource "azuread_application_federated_identity_credential" "github_env_prod" {
  application_id = azuread_application.github_actions_oidc.id
  display_name   = "github-actions-prod"
  description    = "Deployments for GitHub Environment: prod"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_organization}/${var.github_repository}:environment:prod"
}

# Allow generic deployments off the main branch natively (if workflow dispatch wasn't mapped)
resource "azuread_application_federated_identity_credential" "github_branch_main" {
  application_id = azuread_application.github_actions_oidc.id
  display_name   = "github-actions-main-branch"
  description    = "Deployments triggered generically from main branch"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_organization}/${var.github_repository}:ref:refs/heads/main"
}
