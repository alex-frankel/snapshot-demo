@description('The base name for storage resources')
param baseName string

@description('The location for storage resources')
param location string

@description('The SKU for the Storage Account')
param storageSku string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: replace('${baseName}sa', '-', '')
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageSku
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobServices
  name: 'app-data'
  properties: {
    publicAccess: 'None'
  }
}

output storageAccountName string = storageAccount.name
@secure()
output storageConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
