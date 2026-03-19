# Reusable Azure Deployment Framework

This repository provides a robust, reusable GitHub Actions CI/CD framework to seamlessly build and deploy applications to **Azure App Services (Web Apps)** and **Azure Functions**.

It features automated environment scaffolding (Node.js, Python, .NET) and handles the intricacies of zipping and publishing artifacts to Azure natively.

---

## 🏗️ Repository Structure

*   **.github/workflows/reusable-azure-deploy.yml**: The core reusable workflow. It handles the dynamic setup, build, zip, and deployment based on inputs.
*   **.github/workflows/manual-deploy.yml**: The user-facing workflow providing a UI to trigger deployments manually.
*   **src/**: Contains boilerplate sample applications ready for testing:
    *   `webapp-node/`: Sample Node.js Express App for App Service.
    *   `function-python/`: Sample Python Azure Function (v2 HTTP trigger).
    *   `function-node/`: Sample Node.js Azure Function (v4 HTTP trigger).
    *   `function-dotnet/`: Sample .NET 8 Isolated Worker Azure Function.

---

## ⚙️ Prerequisites Configuration (Step-by-Step)

Before you can run a deployment, you need to provide GitHub Actions with the credentials to push code into your Azure resources. This is done securely using an **Azure Publish Profile**.

### Step 1: Get your Publish Profile from Azure
1. Log in to the [Azure Portal](https://portal.azure.com).
2. Navigate to your target **App Service** or **Function App**.
3. On the **Overview** page for that resource, look at the top menu bar.
4. Click **Get publish profile** (or "Download publish profile"). This will download a `.PublishSettings` XML file to your computer.
5. Open that downloaded XML file in any text editor and copy its **entire content**.

### Step 2: Add the Secret to GitHub
1. Navigate to your GitHub repository.
2. Go to **Settings** > **Secrets and variables** > **Actions**.
3. Click the green **New repository secret** button.
4. Set the **Name** exactly to: `AZURE_PUBLISH_PROFILE`
5. Paste the XML content you copied in Step 1 into the **Secret** field.
6. Click **Add secret**.

*(Note: If deploying to multiple environments or different apps frequently, you may want to set up Environment Secrets instead of Repository Secrets).*

---

## 🚀 How to Execute a Manual Deployment

1. Go to the **Actions** tab in your GitHub repository.
2. On the left sidebar, click on **Trigger Azure Deployment**.
3. Click the **Run workflow** dropdown button on the right side of the screen.
4. Fill out the required parameters:
    *   **target_service**: Select either `webapp` or `function`.
    *   **function_runtime**: If deploying a webapp, select `none`. If deploying a Function App, select the language your function uses (`python`, `node`, `dotnet`).
    *   **environment**: Select your target environment tag (e.g., `dev`, `prod`).
    *   **app_name**: Type the *exact* name of your App Service or Function App as it appears in Azure (e.g., `my-company-prod-func`).
5. Click the green **Run workflow** button!

---

## 🔗 How to Automate Deployments (Calling the Reusable Workflow)

While the manual trigger is great for on-demand deployments, you will likely want to deploy automatically when code is merged. You can call the reusable workflow natively from *any* other workflow file (for example, triggering on push to `main`).

Create a file like `.github/workflows/deploy-on-push.yml`:

```yaml
name: Auto Deploy to Production

on:
  push:
    branches:
      - main

jobs:
  call_azure_deployment:
    uses: ./.github/workflows/reusable-azure-deploy.yml
    with:
      target_service: "function"
      function_runtime: "python"
      environment: "prod"
      app_name: "my-azure-production-function"
    secrets:
      PUBLISH_PROFILE: ${{ secrets.AZURE_PUBLISH_PROFILE }}
```

## 🛡️ Features
*   **Fail-fast Validation**: Warns or stops immediately if parameters clash (e.g., deploying a Function but selecting `none` for runtime).
*   **Security First**: Uses explicit `npm install --omit=dev` and Python `.python_packages` mechanisms to keep deployed bundle sizes small and secure.
*   **Latest Tech**: Runs the absolute newest v4/v5 GitHub Actions and V4 Function Programming Models.
