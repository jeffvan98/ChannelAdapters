// 
// Orchestrates resource creation
//

targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment which is used to generate a short unique hash used in all resources.')
param name string

@minLength(1)
@description('Primary location for all resources.')
param location string

@description('Id of the user or app to assign application roles')
param principalId string = ''

@description('The image name for the service')
param imageName string 

var resourceToken = toLower(uniqueString(subscription().id, name, location))
var tags = {
  'azd-env-name': name
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${name}-rg'
  location: location
  tags: tags
}

module resources './resources.bicep' = {
  name: 'resources-${resourceToken}'
  scope: resourceGroup
  params: {
    name: name
    location: location
    principalId: principalId
    imageName: imageName
    resourceToken: resourceToken
    tags: tags
  }
}

output AZURE_CONTAINER_REGISTRY_ENDPOINT string = resources.outputs.AZURE_CONTAINER_REGISTRY_ENDPOINT
