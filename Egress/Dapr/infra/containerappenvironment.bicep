//
// Create a Container App Environment
//

param resourceToken string
param location string
param tags object

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: 'log${resourceToken}'
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: 'mi${resourceToken}'
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
  resource daprComponents 'daprComponents@2022-06-01-preview' = {
    name: 'processmessage'
    properties: {
      componentType: 'bindings.azure.servicebusqueues'
      version: 'v1'
      scopes: [
        'egressdapr'
      ]
      metadata: [
        {
          name: 'azureClientId'
          value: managedIdentity.properties.clientId
        }
        {
          name: 'azureTenantId'
          value: subscription().tenantId
        }
        {
          name: 'namespaceName'
          value: 'sb${resourceToken}.servicebus.windows.net'
        }
        {
          name: 'queueName'
          value: 'queue02'
        }
      ]
    }
  }
}
