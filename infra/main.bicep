targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Tags that should be applied to all resources
var tags = {
  'azd-env-name': environmentName
}

@description('Function App hosting plan type')
@allowed([
  'S1'
  'Consumption'
  'FlexConsumption'
])
param functionPlanType string = 'S1'

// Resource Group Resource
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

// Modules to be deployed within the resource group
module functionResources 'function.bicep' = {
  name: 'function-resources'
  scope: resourceGroup
  params: {
    location: location
    environmentName: environmentName
    functionPlanType: functionPlanType
  }
}

output resourceGroupName string = resourceGroup.name
output functionAppName string = functionResources.outputs.functionAppName
output functionAppHostName string = functionResources.outputs.functionAppHostName
