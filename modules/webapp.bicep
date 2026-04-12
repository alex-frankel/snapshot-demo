@description('The base name for web app resources')
param baseName string

@description('The location for web app resources')
param location string

@description('The SKU for the App Service Plan')
param appServicePlanSku string

@description('The Application Insights connection string')
@secure()
param appInsightsConnectionString string

@description('The storage connection string')
@secure()
param storageConnectionString string

@description('The Key Vault URI')
param keyVaultUri string

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
          value: appInsightsConnectionString
        }
        {
          name: 'STORAGE_CONNECTION_STRING'
          value: storageConnectionString
        }
        {
          name: 'KEY_VAULT_URI'
          value: keyVaultUri
        }
      ]
    }
  }
}

output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
