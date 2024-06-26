# Set your Azure subscription, connection and Function App details
$azureAppSecret = ""
$azureAppId = "8cf8fb35-19b4-43f2-90a6-0e79ae2f250f"
$azureTenantID = "fca0e4d8-0662-4810-8300-c384b3e50f2b"
$subscriptionId = "0dee0052-adfc-4ced-9f1f-ba13b3158f5c"
$storageName = "backupfunappstorage"
$containerName = "resources-data"
$resourceGroupName = "BackupFunctionsRG"

# Setting error action as we are not using try catch
$ErrorActionPreference = "Stop"

# Connect Azure Function
function Connect-AzWithServicePrincipal {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [string]$ClientSecret,

        [Parameter(Mandatory = $false)]
        [string]$SubscriptionId
    )

    process {
        try {
            # Create a PSCredential object
            $secureClientSecret = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
            $psCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ClientId, $secureClientSecret

            # Connect to Azure
            Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $psCredential -ErrorAction Stop

            # Set the subscription context if provided
            if ($PSBoundParameters.ContainsKey('SubscriptionId')) {
                Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction Stop
            }

            Write-Output "Successfully connected to Azure."

        } catch {
            Write-Error "Failed to connect to Azure: $_"
        }
    }
}

# Connect Azure
Connect-AzWithServicePrincipal -TenantId $azureTenantID -ClientId $azureAppId -ClientSecret $azureAppSecret -SubscriptionId $subscriptionId

# Fetching Azure resources, sort and convert to json
Write-Host "Fetching Azure resources data - Start"
$resourcesInJson = Get-AzResource | Sort-Object -Property ResourceType | ConvertTo-Json -Depth 10
Write-Host "Fetching Azure resources data - Completed"

# Create a temporary file
$tempFilePath = [System.IO.Path]::GetTempFileName() + ".json"
Set-Content -Path $tempFilePath -Value $resourcesInJson

# fetch destination storage account
Write-Host "Getting $storageName storage account details - Start"
$storage = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageName
Write-Host "Getting $storageName storage account details - End"

# create a container
Write-Host "Creating storage Container"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
New-AzStorageContainer -Name $containerName-$timestamp -Context $storage.Context
Write-Host "New container is created"

# Uploading json file
Write-Host "Pushing Azure data to container"
Set-AzStorageBlobContent -File $tempFilePath -Container $containerName-$timestamp -Context $storage.Context -Force
Write-Host "JSON Data Successfully uploaded"