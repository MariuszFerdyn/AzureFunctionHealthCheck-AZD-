@description('Environment name (dev/test/prod)')
param environmentName string = 'dev'

@description('Azure region for all resources')
param location string = 'eastus'

@description('Function App hosting plan type')
@allowed([
  'S1'
  'Consumption'
  'FlexConsumption'
])
param functionPlanType string = 'S1'

@description('Base name for resources')
param baseName string = 'pytimerfunc${environmentName}${uniqueString(resourceGroup().id)}'

// Resource Group Resource
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${baseName}'
  location: location
  tags: {
    environment: environmentName
    project: 'python-timer-function'
  }
}

// Modules to be deployed within the resource group
module functionResources 'function.bicep' = {
  name: 'function-resources'
  resourceGroup: resourceGroup.name
  params: {
    location: location
    baseName: baseName
    environmentName: environmentName
    functionPlanType: functionPlanType
  }
}

output resourceGroupName string = resourceGroup.name
output functionAppName string = functionResources.outputs.functionAppName
output functionAppHostName string = functionResources.outputs.functionAppHostName
