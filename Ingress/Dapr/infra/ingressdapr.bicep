// 
// Create Container App
//

param name string
param location string
param imageName string

var resourceToken = toLower(uniqueString(subscription().id, name, location))
var tags = {
  'azd-env-name': name
  'azd-service-name': 'ingressdapr'
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

resource ingressDapr 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: 'caingressdapr'
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
        targetPort: 5239
        transport: 'auto'
      }
      dapr: {
        appId: 'ingressdapr'
        appPort: 5239
        appProtocol: 'http'
        enableApiLogging: true
        enabled: true
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
          name: 'ingressdaprcontainer'
          image: imageName
          env: []
          resources: {
            cpu: json('.25')
            memory: '.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
      }
    }
  }
}
