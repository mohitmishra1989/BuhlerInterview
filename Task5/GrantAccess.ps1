#define variable
$azureAppSecret = ""
$azureAppId = "8cf8fb35-19b4-43f2-90a6-0e79ae2f250f"
$azureTenantID = "fca0e4d8-0662-4810-8300-c384b3e50f2b"
$subscriptionId = "0dee0052-adfc-4ced-9f1f-ba13b3158f5c"
$displayName = "George"
$resourceGroupName = "BackupFunctionsApp1_group"
$functionAppName = "BackupFunctionsApp1"

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


# Get the user object based on display name
$user = Get-AzADUser -Filter "displayName eq '$displayName'"

if ($null -eq $user) {
    Write-Host "User with display name '$displayName' not found."
    exit
}

# Get the Function App
$functionApp = Get-AzFunctionApp -ResourceGroupName $resourceGroupName -Name $functionAppName -Verbose

if ($null -eq $functionApp) {
    Write-Host "Function App '$functionAppName' not found in resource group '$resourceGroupName'."
    exit
}

# Assign the Contributor role to the user for the Function App
New-AzRoleAssignment -ObjectId $user.Id -RoleDefinitionName "Contributor" -Scope $functionApp.Id -Verbose

Write-Host "Contributor access has been granted to user '$displayName' for the Function App '$functionAppName'."
