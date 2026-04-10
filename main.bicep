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

// ---------- Log Analytics Workspace ----------

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${baseName}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: logRetentionDays
  }
}

// ---------- Application Insights ----------

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${baseName}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    RetentionInDays: logRetentionDays
  }
}

// ---------- Storage Account ----------

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

// ---------- App Service Plan ----------

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: '${baseName}-asp'
  location: location
  sku: {
    name: appServicePlanSku
  }
  properties: {
    reserved: true
  }
}

// ---------- Web App ----------

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: '${baseName}-app'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'STORAGE_CONNECTION_STRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'KEY_VAULT_URI'
          value: keyVault.properties.vaultUri
        }
      ]
    }
  }
}

// ---------- Key Vault ----------

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
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
  }
}

resource appInsightsKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'AppInsightsConnectionString'
  properties: {
    value: appInsights.properties.ConnectionString
  }
}

// ---------- Outputs ----------

output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output keyVaultUri string = keyVault.properties.vaultUri
output storageAccountName string = storageAccount.name
output appInsightsName string = appInsights.name
output logAnalyticsId string = logAnalytics.id
