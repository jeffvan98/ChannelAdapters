//
// Create a Container App Environment
//

param resourceToken string
param location string
param tags object

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: 'log${resourceToken}'
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-06-01-preview' = {
  name: 'cae${resourceToken}'
  location: location
  tags: tags
  sku: {
    name: 'Consumption'
  }
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}
