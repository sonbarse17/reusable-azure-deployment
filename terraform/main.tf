locals {
  base_name = "${var.project_name}-${var.environment}"

  default_tags = merge(var.tags, {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  })
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.base_name}"
  location = var.location
  tags     = local.default_tags
}

resource "azurerm_resource_group" "rg_func" {
  name     = "rg-${local.base_name}-func"
  location = var.location
  tags     = local.default_tags
}

resource "azurerm_storage_account" "sa" {
  name                     = "st${var.project_name}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = local.default_tags
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${local.base_name}-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = local.default_tags
}

resource "azurerm_application_insights" "appi" {
  name                = "appi-${local.base_name}-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "web"
  tags                = local.default_tags
}

resource "azurerm_service_plan" "webapp_plan" {
  name                = "asp-webapp-${local.base_name}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.webapp_sku
  tags                = local.default_tags
}

resource "azurerm_service_plan" "function_plan" {
  name                = "asp-func-${local.base_name}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg_func.name
  location            = azurerm_resource_group.rg_func.location
  os_type             = "Linux"
  sku_name            = var.function_sku
  tags                = local.default_tags
}

resource "azurerm_linux_web_app" "webapp_python" {
  name                = "app-python-${local.base_name}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.webapp_plan.location
  service_plan_id     = azurerm_service_plan.webapp_plan.id
  tags                = local.default_tags

  site_config {
    application_stack {
      python_version = var.python_version
    }
    always_on = var.webapp_sku != "F1" ? true : false
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.appi.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appi.connection_string
  }
}

resource "azurerm_linux_web_app_slot" "webapp_python_dev" {
  name           = "dev"
  app_service_id = azurerm_linux_web_app.webapp_python.id
  tags           = local.default_tags

  site_config {
    application_stack {
      python_version = var.python_version
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.appi.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appi.connection_string
  }
}

resource "azurerm_linux_web_app_slot" "webapp_python_uat" {
  name           = "uat"
  app_service_id = azurerm_linux_web_app.webapp_python.id
  tags           = local.default_tags

  site_config {
    application_stack {
      python_version = var.python_version
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.appi.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appi.connection_string
  }
}

resource "azurerm_linux_function_app" "func_node" {
  name                       = "func-node-${local.base_name}-${random_string.suffix.result}"
  resource_group_name        = azurerm_resource_group.rg_func.name
  location                   = azurerm_resource_group.rg_func.location
  service_plan_id            = azurerm_service_plan.function_plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  tags                       = local.default_tags

  site_config {
    application_stack {
      node_version = var.node_version
    }
    application_insights_key               = azurerm_application_insights.appi.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.appi.connection_string
  }
}

resource "azurerm_linux_function_app_slot" "func_node_dev" {
  name            = "dev"
  function_app_id = azurerm_linux_function_app.func_node.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  tags                       = local.default_tags

  site_config {
    application_stack {
      node_version = var.node_version
    }
    application_insights_key               = azurerm_application_insights.appi.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.appi.connection_string
  }
}

resource "azurerm_linux_function_app_slot" "func_node_uat" {
  name            = "uat"
  function_app_id = azurerm_linux_function_app.func_node.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  tags                       = local.default_tags

  site_config {
    application_stack {
      node_version = var.node_version
    }
    application_insights_key               = azurerm_application_insights.appi.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.appi.connection_string
  }
}

resource "azurerm_linux_function_app" "func_python" {
  name                       = "func-python-${local.base_name}-${random_string.suffix.result}"
  resource_group_name        = azurerm_resource_group.rg_func.name
  location                   = azurerm_resource_group.rg_func.location
  service_plan_id            = azurerm_service_plan.function_plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  tags                       = local.default_tags

  site_config {
    application_stack {
      python_version = var.python_version
    }
    application_insights_key               = azurerm_application_insights.appi.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.appi.connection_string
  }
}

resource "azurerm_linux_function_app_slot" "func_python_dev" {
  name            = "dev"
  function_app_id = azurerm_linux_function_app.func_python.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  tags                       = local.default_tags

  site_config {
    application_stack {
      python_version = var.python_version
    }
    application_insights_key               = azurerm_application_insights.appi.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.appi.connection_string
  }
}

resource "azurerm_linux_function_app_slot" "func_python_uat" {
  name            = "uat"
  function_app_id = azurerm_linux_function_app.func_python.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  tags                       = local.default_tags

  site_config {
    application_stack {
      python_version = var.python_version
    }
    application_insights_key               = azurerm_application_insights.appi.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.appi.connection_string
  }
}

resource "azurerm_linux_function_app" "func_dotnet" {
  name                       = "func-dotnet-${local.base_name}-${random_string.suffix.result}"
  resource_group_name        = azurerm_resource_group.rg_func.name
  location                   = azurerm_resource_group.rg_func.location
  service_plan_id            = azurerm_service_plan.function_plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  tags                       = local.default_tags

  site_config {
    application_stack {
      dotnet_version              = var.dotnet_version
      use_dotnet_isolated_runtime = true
    }
    application_insights_key               = azurerm_application_insights.appi.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.appi.connection_string
  }
}

resource "azurerm_linux_function_app_slot" "func_dotnet_dev" {
  name            = "dev"
  function_app_id = azurerm_linux_function_app.func_dotnet.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  tags                       = local.default_tags

  site_config {
    application_stack {
      dotnet_version              = var.dotnet_version
      use_dotnet_isolated_runtime = true
    }
    application_insights_key               = azurerm_application_insights.appi.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.appi.connection_string
  }
}

resource "azurerm_linux_function_app_slot" "func_dotnet_uat" {
  name            = "uat"
  function_app_id = azurerm_linux_function_app.func_dotnet.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  tags                       = local.default_tags

  site_config {
    application_stack {
      dotnet_version              = var.dotnet_version
      use_dotnet_isolated_runtime = true
    }
    application_insights_key               = azurerm_application_insights.appi.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.appi.connection_string
  }
}
