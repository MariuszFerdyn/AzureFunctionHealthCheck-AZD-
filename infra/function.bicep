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
    // Conditionally set serverFarmId based on the function plan type
    serverFarmId: functionPlanType == 'Consumption' ? null : appServicePlan.id
    
    // Additional configuration to support different hosting plans
    siteConfig: {
      // Consumption and Flex Consumption plans don't require an App Service Plan
      functionAppScaleLimit: functionPlanType == 'Consumption' ? 200 : null
      
      // Elastic (Flex Consumption) specific settings
      elastic: functionPlanType == 'FlexConsumption' ? {
        maximumInstanceCount: 100 // Configurable based on your needs
      } : null
    }
  }
}

output functionAppName string = functionApp.name
output functionAppHostName string = functionApp.properties.defaultHostName
