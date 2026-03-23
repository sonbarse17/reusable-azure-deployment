# Reusable Azure Deployment Architecture

## Overview
This repository contains a full production-grade, enterprise-scale CI/CD deployment system for Azure. It securely automates the deployment of **Azure Web Apps (Python)** and **Azure Function Apps (Python, Node, .NET)** using strictly modular GitHub Actions. 

## Key Enterprise Features
- **Two Distinct Reusable Workflows**: Features separate `reusable-webapp-deploy.yml` and `reusable-function-deploy.yml` files for strict separation of concerns.
- **Credential-less OIDC Authentication**: Zero passwords or XML publishing profiles. Authenticates securely to Azure Active Directory via temporary OpenID Connect (OIDC) identity federation.
- **Dynamic Slot Routing & Environments**: Intelligently maps deployments natively to Azure Slots (`dev`, `uat`, `production`) and triggers native GitHub protection rules.
- **Dynamic Environment URLs**: GitHub automatically links your deployed Azure Application URL directly in your Repository "Environments" tab using calculated Action expressions.
- **Zero-Bash Execution**: Fully mathematical calculated ternary parameters inside the workflow, minimizing action runner boot times and bash syntax vulnerabilities.
- **Least-Privilege Security Model**: Strict global `permissions: {}` defaults, with `id-token` write access tightly bound exclusively to the singular deployment blocks.

---

## Workflow File Architecture
1. **`.github/workflows/manual-deploy.yml`**: The User Interface. Gives developers a dropdown menu to select their Target Service, Runtime, Version, Target Slot, and Target Code Path.
2. **`.github/workflows/reusable-webapp-deploy.yml`**: The Web App engine. Contains pure Python Web App deployment logic using `azure/webapps-deploy@v3`.
3. **`.github/workflows/reusable-function-deploy.yml`**: The Function engine. Contains perfectly dynamic multi-language (Node, Python, .NET) Function App logic using `azure/functions-action@v1`.

---

## 🏢 Step 1: Provision Infrastructure & OIDC Identities
Because this system is built to strict production standards, you do not need to click around the Azure AD portal. The included Terraform automatically mints the OpenID Connect (OIDC) Service Principal, scopes role assignments, and builds federated credentials.

1. Navigate to the `terraform` directory:
   ```bash
   cd terraform
   ```
2. Initialize and deploy:
   ```bash
   terraform init
   terraform apply -var="subscription_id=<YOUR_SUB_ID>" -var="tenant_id=<YOUR_TENANT_ID>"
   ```
3. When the Terraform apply completes, it will securely output three values:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`

---

## 🔐 Step 2: Configure GitHub Repository Secrets
To link your new automated Identity exactly to this repository:
1. Go to your repository on GitHub and click **Settings**.
2. Go to **Secrets and variables** > **Actions** on the left menu.
3. Add the three specific Outputs from Step 1 as Repository Secrets.

---

## 🌍 Step 3: Configure GitHub Environments
To take full advantage of the dynamic deployment protection rules engineered into this pipeline, enable GitHub Environments natively:
1. Stay in your GitHub **Settings**.
2. Click **Environments** on the left menu.
3. Click **"New environment"** and name them exactly: `prod`, `uat`, and `dev` (case sensitive).
4. Optionally check **"Required reviewers"** inside of `prod` to mandate manual human approval before any code executes against the `production` Azure slot.
5. *Magic:* The pipelines natively intercept your manual framework choices and automatically attach your deployments to the correct GitHub Environments—even generating a clickable live link to your active endpoint right in the Azure UI!

---

## 🚀 Step 4: Run Azure Deployments
1. Go to your repository's **Actions** tab on GitHub.
2. Select **"Trigger Azure Deployment"** in the left sidebar.
3. Click the **"Run workflow"** button on the right.
4. Provide the EXACT settings for your application:
   - **Target Service:** `webapp` or `function`
   - **Deployment Slot:** `dev`, `uat`, `production`
   - **Application Runtime:** `python`, `node`, `dotnet`  *(Note: Web Apps only support python in this configuration)*
   - **Runtime Version:** e.g. `3.11`, `20`, or `8.0.x`
   - **Azure Resource Name:** `func-my-app-dev-xxxxx`
   - **Working Directory:** Leaving it as `.` will auto-calculate `./src/[service]-[runtime]`. Or specify a custom folder!
