subscription_id     = "abdce7f4-417e-468e-98ca-1699b76ed019"
resource_group_name = "reusable-deploy"
location            = "Central US"
environment         = "dev"
project_name        = "azuredeploy"

webapp_sku   = "F1"
function_sku = "Y1"

node_version   = "20"
python_version = "3.11"
dotnet_version = "8.0"

log_retention_days = 30

tags = {
  owner   = "sushant"
  purpose = "reusable-azure-deployment-demo"
}
