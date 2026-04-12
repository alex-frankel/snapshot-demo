@description('The base name for Key Vault resources')
param baseName string

@description('The location for Key Vault resources')
param location string

@description('The SKU for the Key Vault')
param kvSku string

@description('The storage connection string to store as a secret')
@secure()
param storageConnectionString string

@description('The Application Insights connection string to store as a secret')
@secure()
param appInsightsConnectionString string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${baseName}-kv'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: kvSku
    }
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
}

resource storageConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'StorageConnectionString'
  properties: {
    value: storageConnectionString
  }
}

resource appInsightsKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'AppInsightsConnectionString'
  properties: {
    value: appInsightsConnectionString
  }
}

output keyVaultUri string = keyVault.properties.vaultUri
