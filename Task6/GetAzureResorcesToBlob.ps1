## Connecting to the azure account using secret id
$azureAppSecret = #ClientSecret
$azureAppId = #ClientID
$azureTenantID = #AzureTenentID
$password = ConvertTo-SecureString $azureAppSecret -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($azureAppId,$azureAppSecret)
Connect-AzAccount -