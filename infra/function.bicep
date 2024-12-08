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

// Variable declarations
var functionAppName = '${environmentName}-function'
var appServicePlanName = '${environmentName}-plan'
var storageAccountName = replace('${environmentName}sa', '-', '')

// Storage Account resource
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  tags: tags
}

// App Service Plan resource - Linux configuration
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = if (functionPlanType != 'Consumption') {
  name: appServicePlanName
  location: location
  sku: {
    name: functionPlanType == 'S1' ? 'S1' : 'EP1'
  }
  kind: 'linux'
  properties: {
    reserved: true // This explicitly sets the plan to Linux
  }
  tags: tags
}

// Function App resource
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  
  // Add system-assigned managed identity
  identity: {
    type: 'SystemAssigned'
  }
  
  tags: {
    'azd-env-name': environmentName
    'azd-service-name': 'HealthCheckFunction'
  }
  properties: {
    // Conditionally set serverFarmId based on the function plan type
    serverFarmId: functionPlanType == 'Consumption' ? null : appServicePlan.id
    // Enhanced site configuration
    siteConfig: {
      // Python-specific configuration
      pythonVersion: '3.11'
      linuxFxVersion: 'python|3.11'
      
      // Consumption and Flex Consumption plans don't require an App Service Plan
      functionAppScaleLimit: functionPlanType == 'Consumption' ? 200 : null
     
      // Elastic (Flex Consumption) specific settings
      elastic: functionPlanType == 'FlexConsumption' ? {
        maximumInstanceCount: 100 // Configurable based on your needs
      } : null
      
      // App settings for Function App
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT' 
          value: 'true'
        }
        {
          name: 'ENABLE_ORYX_BUILD'  
          value: 'true'
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

// Outputs remain the same
output functionAppName string = functionApp.name
output functionAppHostName string = functionApp.properties.defaultHostName
