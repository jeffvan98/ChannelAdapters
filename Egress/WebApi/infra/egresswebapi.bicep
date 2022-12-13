// 
// Create Container App
//

param name string
param location string
param imageName string

var resourceToken = toLower(uniqueString(subscription().id, name, location))
var tags = {
  'azd-env-name': name
  'azd-service-name': 'egresswebapi'
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: 'mi${resourceToken}'
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-06-01-preview' existing = {
  name: 'cae${resourceToken}'
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: 'acr${resourceToken}'
}

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: 'sb${resourceToken}'
}

resource ingressWebApi 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: 'caegresswebapi'
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 5249
        transport: 'auto'
      }
      registries: [
        {
          identity: managedIdentity.id
          server: containerRegistry.properties.loginServer
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'egresswebapicontainer'
          image: imageName
          env: [
            {
              name: 'AZURE_CLIENT_ID'
              value: managedIdentity.properties.clientId
            }
            {
              name: 'AzureDefaults__Retry__MaxRetries'
              value: '3'
            }
            {
              name: 'AzureDefaults__Retry__Mode'
              value: 'Exponential'
            }
            {
              name: 'ServiceBus__FullyQualifiedNamespace'
              value: '${serviceBusNamespace.name}.servicebus.windows.net'
            }
            {
              name: 'EgressWebApi__Queue'
              value: 'queue01'
            }
          ]
          resources: {
            cpu: json('.25')
            memory: '.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}
