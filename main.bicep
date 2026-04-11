@description('The base name for all resources')
param baseName string

@description('The location for all resources')
param location string

@description('The SKU for the App Service Plan')
param appServicePlanSku string = 'S1'

@description('The SKU for the Storage Account')
param storageSku string = 'Standard_LRS'

@description('The SKU for the Key Vault')
param kvSku string = 'standard'

@description('Log retention in days')
param logRetentionDays int = 30

// ---------- Monitoring ----------

module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    baseName: baseName
    location: location
    logRetentionDays: logRetentionDays
  }
}

// ---------- Storage ----------

module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    baseName: baseName
    location: location
    storageSku: storageSku
  }
}

// ---------- Key Vault ----------

module keyvault 'modules/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    baseName: baseName
    location: location
    kvSku: kvSku
    storageConnectionString: storage.outputs.storageConnectionString
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
  }
}

// ---------- Web App ----------

module webapp 'modules/webapp.bicep' = {
  name: 'webapp'
  params: {
    baseName: baseName
    location: location
    appServicePlanSku: appServicePlanSku
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
    storageConnectionString: storage.outputs.storageConnectionString
    keyVaultUri: keyvault.outputs.keyVaultUri
  }
}

// ---------- Outputs ----------

output webAppUrl string = webapp.outputs.webAppUrl
output keyVaultUri string = keyvault.outputs.keyVaultUri
output storageAccountName string = storage.outputs.storageAccountName
output appInsightsName string = monitoring.outputs.appInsightsName
output logAnalyticsId string = monitoring.outputs.logAnalyticsId
