@description('Azure region for the resources')
param location string

@description('Environment name')
param environmentName string

@description('Tags to be applied to resources')
param tags object

@description('Function App hosting plan type')
@allowed([
  'S1'
  'Consumption'
  'FlexConsumption'
])
param functionPlanType string = 'S1'

var functionAppName = '${environmentName}-function'
var appServicePlanName = '${environmentName}-plan'
var storageAccountName = replace('${environmentName}sa', '-', '')

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  tags: tags
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = if (functionPlanType != 'Consumption') {
  name: appServicePlanName
  location: location
  sku: {
    name: functionPlanType == 'S1' ? 'S1' : 'EP1'
  }
  kind: functionPlanType == 'FlexConsumption' ? 'elastic' : 'functionapp'
  tags: tags
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  tags: tags
  properties: {
    serverFarmId: functionPlanType == 'Consumption' ? null : appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.10'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
      ]
    }
  }
}

output functionAppName string = functionApp.name
output functionAppHostName string = functionApp.properties.defaultHostName
