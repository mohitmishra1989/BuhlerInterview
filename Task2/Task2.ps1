$csvFileName = "goodreads_cleaned.csv"
$homePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$position = 0
Import-Csv -Path $homePath\$csvFileName | Format-List -Property bookTitle, average_rating, @{Name="Position"; Expression={$script:position++; $script:position}}