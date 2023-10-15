param rgName string = 'MyResourceGroup'
param locationName string = 'eastus'
targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: locationName
}
