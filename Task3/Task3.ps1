<#
.Synopsis
    Read a JSON file, modify its properties, merge with another CSV, and save the result as a CSV
.DESCRIPTION
    Read a JSON file, Remove one of its property, fetch other properties of the same object from a CSV file on the basis, and save the output in a CSV. Name property will act as a the primary unique property to corelate.
.EXAMPLE
   Generate-OutputCsv -JsonFileName tv_shows_and_movies_sample.json -CsvFileName movies.csv -RemoveProperties @("scraped_at") -MovePropertiesFromCSV @("imbd_votes") -OutputFileNameInCsv output.csv
.EXAMPLE
   $params = @{
        JsonFileName = "tv_shows_and_movies_sample.json"
        CsvFileName = "movies.csv"
        RemoveProperties = @("scraped_at")
        MovePropertiesFromCSV = @("imbd_votes")
        OutputFileNameInCsv = "output.csv"
    }
    Generate-OutputCsv @params
    This example shows how to use a hash table to pass parameters to the function.
#>
function Generate-OutputCsv
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The path to the JSON file.")]
        [ValidateNotNullOrEmpty()]
        [string]$JsonFileName,

        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "The path to the CSV File.")]
        [ValidateNotNullOrEmpty()]
        [string]$CsvFileName,

        [Parameter(Mandatory = $true, Position = 2, HelpMessage = "List of properties which needs to be Removed from json.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$RemoveProperties,

        [Parameter(Mandatory = $true, Position = 3, HelpMessage = "List of properties which needs to be moved from CSV.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$MovePropertiesFromCSV,

        [Parameter(Mandatory = $true, Position = 3, HelpMessage = "List of properties which needs to be moved from CSV.")]
        [ValidateNotNullOrEmpty()]
        [string]$OutputFileNameInCsv
    )

    Begin
    {
        $homeDir = Split-Path -Parent $MyInvocation.PSCommandPath
    }
    Process
    {
    try{
        $jsonObject = Get-Content -Path $homeDir\$JsonFileName -Raw | ConvertFrom-Json
        $csvObject = Import-Csv -Path $homeDir\$CsvFileName
        foreach($object in $jsonObject){
            $RemoveProperties | Foreach-Object {$object.PSObject.Properties.Remove($_)}
            $commonObject = ($csvObject | Where-Object{$_.name.trim() -eq $object.name.Trim()})
            $MovePropertiesFromCSV | Foreach-Object{
                $property = $_;
                Add-Member -InputObject $object -MemberType NoteProperty -Name $property -Value $commonObject.$property
                }
            }  
    }catch{Throw "Failed"}
    }
    End
    {
        $jsonObject | Export-Csv -Path $homeDir\$OutputFileNameInCsv -NoTypeInformation -Force
    }
}

Generate-OutputCsv -JsonFileName tv_shows_and_movies_sample.json -CsvFileName movies.csv -RemoveProperties @("scraped_at") -MovePropertiesFromCSV @("imbd_votes") -OutputFileNameInCsv output.csv