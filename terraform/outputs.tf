output "resource_group_name" {
  description = "Name of the Web App Resource Group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_func_name" {
  description = "Name of the Function Apps Resource Group"
  value       = azurerm_resource_group.rg_func.name
}

output "webapp_node_name" {
  description = "Name of the Node.js Web App (use in GitHub Actions app_name)"
  value       = azurerm_linux_web_app.webapp_node.name
}

output "webapp_node_url" {
  description = "Default hostname URL of the Node.js Web App"
  value       = "https://${azurerm_linux_web_app.webapp_node.default_hostname}"
}

output "function_node_name" {
  description = "Name of the Node.js Function App (use in GitHub Actions app_name)"
  value       = azurerm_linux_function_app.func_node.name
}

output "function_node_url" {
  description = "Default hostname URL of the Node.js Function App"
  value       = "https://${azurerm_linux_function_app.func_node.default_hostname}"
}

output "function_python_name" {
  description = "Name of the Python Function App (use in GitHub Actions app_name)"
  value       = azurerm_linux_function_app.func_python.name
}

output "function_python_url" {
  description = "Default hostname URL of the Python Function App"
  value       = "https://${azurerm_linux_function_app.func_python.default_hostname}"
}

output "function_dotnet_name" {
  description = "Name of the .NET Function App (use in GitHub Actions app_name)"
  value       = azurerm_linux_function_app.func_dotnet.name
}

output "function_dotnet_url" {
  description = "Default hostname URL of the .NET Function App"
  value       = "https://${azurerm_linux_function_app.func_dotnet.default_hostname}"
}

output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = azurerm_application_insights.appi.name
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.sa.name
}
