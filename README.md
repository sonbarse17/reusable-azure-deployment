# Reusable Azure Deployment Framework

A production-ready, reusable GitHub Actions CI/CD framework to build and deploy applications to **Azure App Services (Web Apps)** and **Azure Functions** — across Node.js, Python, and .NET runtimes.

---

## 📁 Repository Structure

```
.
├── .github/
│   └── workflows/
│       ├── reusable-azure-deploy.yml   # Core reusable workflow (build + deploy engine)
│       └── manual-deploy.yml           # User-facing manual trigger workflow
├── src/
│   ├── webapp-node/                    # Sample Node.js Express Web App
│   ├── function-node/                  # Sample Node.js Azure Function (v4 model)
│   ├── function-python/                # Sample Python Azure Function (v2 model)
│   └── function-dotnet/                # Sample .NET 8 Isolated Azure Function
└── terraform/
    ├── providers.tf                    # Azure provider configuration
    ├── variables.tf                    # Input variable declarations
    ├── main.tf                         # All Azure resource definitions
    ├── outputs.tf                      # Output values (app names, URLs)
    └── terraform.tfvars                # Your environment-specific values
```

---

## 🚀 End-to-End Deployment Guide

Follow these steps in order to go from zero to a fully deployed application on Azure.

---

### Step 1 — Prerequisites

Make sure you have the following installed and configured locally:

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5.0
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- An active **Azure Subscription**

Login to Azure via the CLI:

```bash
az login
```

---

### Step 2 — Configure Terraform Variables

Open `terraform/terraform.tfvars` and fill in your values:

```hcl
subscription_id     = "your-azure-subscription-id"   # az account show --query id -o tsv
resource_group_name = "reusable-deploy"
location            = "Central US"
environment         = "dev"
project_name        = "azuredeploy"

webapp_sku   = "F1"    # Free tier. Use B1/S1 for paid tiers.
function_sku = "Y1"    # Y1 = Consumption (free). Use EP1 for Premium.

node_version   = "20"
python_version = "3.11"
dotnet_version = "8.0"

log_retention_days = 30

tags = {
  owner   = "your-name"
  purpose = "azure-deployment-demo"
}
```

> **Note:** The `F1` (Free) and `Y1` (Consumption) SKUs require separate resource groups.
> Terraform handles this automatically — the Web App and Function Apps will be placed in
> different resource groups.

---

### Step 3 — Provision Azure Infrastructure with Terraform

```bash
cd terraform/

# Initialize providers
terraform init

# Preview what will be created (optional but recommended)
terraform plan

# Create all Azure resources
terraform apply --auto-approve
```

Once complete, Terraform will output the exact names and URLs of all provisioned resources:

```
Outputs:

application_insights_name = "appi-azuredeploy-dev-xxxxxx"
function_dotnet_name      = "func-dotnet-azuredeploy-dev-xxxxxx"
function_dotnet_url       = "https://func-dotnet-azuredeploy-dev-xxxxxx.azurewebsites.net"
function_node_name        = "func-node-azuredeploy-dev-xxxxxx"
function_node_url         = "https://func-node-azuredeploy-dev-xxxxxx.azurewebsites.net"
function_python_name      = "func-python-azuredeploy-dev-xxxxxx"
function_python_url       = "https://func-python-azuredeploy-dev-xxxxxx.azurewebsites.net"
resource_group_func_name  = "rg-azuredeploy-dev-func"
resource_group_name       = "rg-azuredeploy-dev"
storage_account_name      = "stazuredeployxxxxxx"
webapp_node_name          = "app-node-azuredeploy-dev-xxxxxx"
webapp_node_url           = "https://app-node-azuredeploy-dev-xxxxxx.azurewebsites.net"
```

> **Save these output values** — you will need the app names in Steps 4 and 6.

---

### Step 4 — Get Azure Publish Profiles

Each Azure app has its own Publish Profile (credentials for deployment). Fetch all 4 using the Azure CLI. Replace the names below with your actual Terraform output values:

```bash
# 1. Node.js Web App
az webapp deployment list-publishing-profiles \
  --name "<webapp_node_name>" \
  --resource-group "<resource_group_name>" \
  --xml

# 2. Node.js Function App
az functionapp deployment list-publishing-profiles \
  --name "<function_node_name>" \
  --resource-group "<resource_group_func_name>" \
  --xml

# 3. Python Function App
az functionapp deployment list-publishing-profiles \
  --name "<function_python_name>" \
  --resource-group "<resource_group_func_name>" \
  --xml

# 4. .NET Function App
az functionapp deployment list-publishing-profiles \
  --name "<function_dotnet_name>" \
  --resource-group "<resource_group_func_name>" \
  --xml
```

Copy the full XML output from each command — you'll need it in the next step.

---

### Step 5 — Add GitHub Secrets

Navigate to your GitHub repository:
**Settings → Secrets and variables → Actions → New repository secret**

Add the following **4 secrets**, pasting the full XML from Step 4 as the value for each:

| Secret Name | Value |
|---|---|
| `AZURE_PUBLISH_PROFILE_WEBAPP_NODE` | XML output from the Node.js Web App command |
| `AZURE_PUBLISH_PROFILE_FUNC_NODE` | XML output from the Node.js Function command |
| `AZURE_PUBLISH_PROFILE_FUNC_PYTHON` | XML output from the Python Function command |
| `AZURE_PUBLISH_PROFILE_FUNC_DOTNET` | XML output from the .NET Function command |

> ⚠️ **Security:** These secrets contain live deployment credentials. Never commit them to source code. They are protected by GitHub's encrypted secrets store once added.

---

### Step 6 — Trigger a Deployment

1. Go to the **Actions** tab in your GitHub repository.
2. Click **Trigger Azure Deployment** in the left sidebar.
3. Click the **Run workflow** dropdown.
4. Fill in the parameters:

| Parameter | Description | Example Values |
|---|---|---|
| `target_service` | Type of Azure resource | `webapp` or `function` |
| `function_runtime` | Runtime language (functions only) | `none`, `python`, `node`, `dotnet` |
| `environment` | Target environment tag | `dev`, `uat`, `prod` |
| `app_name` | **Exact Azure resource name** from Terraform output | `app-node-azuredeploy-dev-xxxxxx` |

5. Click the green **Run workflow** button.

#### Example Combinations

| Deploying | `target_service` | `function_runtime` | `app_name` |
|---|---|---|---|
| Node.js Web App | `webapp` | `none` | `app-node-azuredeploy-dev-xxxxxx` |
| Node.js Function | `function` | `node` | `func-node-azuredeploy-dev-xxxxxx` |
| Python Function | `function` | `python` | `func-python-azuredeploy-dev-xxxxxx` |
| .NET Function | `function` | `dotnet` | `func-dotnet-azuredeploy-dev-xxxxxx` |

> ℹ️ The workflow will automatically use the correct publish profile secret based on the combination of `target_service` and `function_runtime` you select.

---

### Step 7 — Verify Deployment

Once the workflow completes successfully, open the URL from the Terraform output in your browser to verify your app is live:

```
https://<app_name>.azurewebsites.net
```

---

## 🔗 Calling the Reusable Workflow Automatically

To trigger deployments automatically on code push (e.g., on merge to `main`), create a new file `.github/workflows/deploy-on-push.yml`:

```yaml
name: Auto Deploy on Push

on:
  push:
    branches:
      - main

jobs:
  deploy:
    uses: ./.github/workflows/reusable-azure-deploy.yml
    with:
      target_service: "function"
      function_runtime: "python"
      environment: "prod"
      app_name: "func-python-azuredeploy-prod-xxxxxx"
    secrets:
      PUBLISH_PROFILE_FUNC_PYTHON: ${{ secrets.AZURE_PUBLISH_PROFILE_FUNC_PYTHON }}
```

---

## 🏗️ How the Workflow Works

```
manual-deploy.yml  (you trigger this)
       │
       ├── validates inputs (fail-fast if function + runtime=none)
       │
       └── calls reusable-azure-deploy.yml with:
                │
                ├── BUILD JOB
                │     ├── Checkout source code
                │     ├── Setup runtime (Node/Python/.NET) based on inputs
                │     ├── Install dependencies / publish release build
                │     ├── Zip the artifact
                │     └── Upload zip as GitHub Actions artifact
                │
                └── DEPLOY JOB (runs after build)
                      ├── Download the zip artifact
                      └── Push to Azure using the matching publish profile
```

---

## 🧹 Tear Down Infrastructure

To destroy all Azure resources created by Terraform:

```bash
cd terraform/
terraform destroy --auto-approve
```

---

## 🛡️ Features

- **Fail-fast Validation:** Stops immediately if parameters conflict (e.g., `function` selected but `runtime=none`)
- **Reusable by Design:** The core workflow accepts generic inputs — works for any Azure app name
- **Per-app Secrets:** Each app has its own publish profile secret — no credential swapping needed
- **Tagging:** All resources are tagged with `environment`, `project`, and `managed_by` for cost tracking
- **Observability:** Application Insights and Log Analytics Workspace provisioned for all apps
- **Security:** Production dependencies only (`--omit=dev`), `.python_packages` isolation for Python
