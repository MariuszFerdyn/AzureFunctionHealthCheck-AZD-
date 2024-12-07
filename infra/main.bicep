param location string = resourceGroup().location
param functionAppName string
param storageAccountName string
@allowed([
  'S1'
  'Y1'
  'EP1'
])
param skuName string = 'S1'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'functionAppServicePlan'
  location: location
  sku: {
    name: skuName
    tier: skuName == 'S1' ? 'Standard' : (skuName == 'Y1' ? 'Dynamic' : 'PremiumV2')
  }
  kind: 'FunctionApp'
}

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccount.properties.primaryEndpoints.blob
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
      ]
    }
  }
}

output functionAppEndpoint string = functionApp.properties.defaultHostName
