# AzureFunctionHealthCheck
This project can be used for creating the Azure Function for Health Check.
The following can be checked
- ping
- http status
- http string
- ICAP server processing (needs )

See config: https://github.com/MariuszFerdyn/AzureFunctionHealthCheck-AZD-.git/blob/main/config.yml

# Start with clone the repo
```
git clone https://github.com/MariuszFerdyn/AzureFunctionHealthCheck-AZD-.git
```

# Run project locally
```
# Navigate to your function app directory
Set-Location -Path AzureFunctionHealthCheck-AZD
# Create a virtual environment in the current directory
py -m venv .venv
# Activate the virtual environment
.venv\scripts\activate
# Open the project in Visual Studio Code
code .
  ```

- Press F1 and choose ```Azurite: Start```
- Install dependencies ```pip install -r requirements.txt```
- Start function locally ```func start --verbose```
# Publish Function To Azure (To avoid transfering unnessesary files do the deployment after checkout/clone the reposiy - not after running locally)
```
# Navigate to your function app directory
Set-Location -Path AzureFunctionHealthCheck-AZD

# Deploy the Soultion to Azure
az login
az account show
az account set --subscription <subscription-id>
azd auth login
# Deploy solution
azd up
```
