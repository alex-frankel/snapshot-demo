using './main.bicep'

param baseName = 'snapshot-demo'
param location = 'eastus2'
param appServicePlanSku = 'S1'
param storageSku = 'Standard_LRS'
param kvSku = 'standard'
param logRetentionDays = 30
