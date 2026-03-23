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

## 🔐 Setup Authentication (OIDC)
Because this system is highly secure, it does not use hardcoded publishing secrets. You must set up OIDC Trust:
1. Register a new application in Microsoft Entra ID (Azure Active Directory).
2. Go to `Certificates & secrets` > `Federated credentials` > Add a credential for "GitHub Actions" pointing strictly to this repository.
3. Grant your new Service Principal `Contributor` (or scoped WebApp Contributor) rights to your Resource Group.
4. Add the following repository secrets to GitHub:
   - `AZURE_CLIENT_ID`: (Your Application/Client ID)
   - `AZURE_TENANT_ID`: (Your Directory/Tenant ID)
   - `AZURE_SUBSCRIPTION_ID`: (Your Subscription ID)

---

## 🚀 How to Run Deployments
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
