//
// Create required resources
//

param name string
param location string
param principalId string
param imageName string
param resourceToken string
param tags object

module logAnalyticsResources './loganalytics.bicep' = {
  name: 'logAnalyticsResources'
  params: {
    resourceToken: resourceToken
    location: location
    tags: tags
  }
}

module containerAppEnvironmentResources './containerappenvironment.bicep' = {
  name: 'containerAppEnvironmentResources'
  params: {
    resourceToken: resourceToken
    location: location
    tags: tags
  }
  dependsOn: [
    logAnalyticsResources
  ]  
}

module managedIdentityResources './managedidentity.bicep' = {
  name: 'managedIdentityResources'
  params: {
    resourceToken: resourceToken
    location: location
    tags: tags
  }  
}

module containerRegistryResources './containerregistry.bicep' = {
  name: 'containerRegistryResources'
  params: {
    resourceToken: resourceToken
    location: location
    tags: tags
  }
  dependsOn: [
    managedIdentityResources
  ]
}

module serviceBusResources './servicebus.bicep' = {
  name: 'serviceBusResources'
  params: {
    resourceToken: resourceToken
    location: location
    tags: tags
  }
  dependsOn: [
    managedIdentityResources
  ]
} 

module egressDaprResources './egressdapr.bicep' = {
  name: 'egressdapr'
  params: {
    name: name
    location: location
    imageName: imageName != '' ? imageName : 'mcr.microsoft.com/dotnet/samples:aspnetapp'
  }
  dependsOn: [
    managedIdentityResources
    containerAppEnvironmentResources
    containerRegistryResources
    serviceBusResources
  ]
}

output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistryResources.outputs.AZURE_CONTAINER_REGISTRY_ENDPOINT
