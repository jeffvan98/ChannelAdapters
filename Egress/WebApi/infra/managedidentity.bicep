//
// Create a managed identity
//

param resourceToken string
param location string
param tags object

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'mi${resourceToken}'
  location: location
  tags: tags
}
