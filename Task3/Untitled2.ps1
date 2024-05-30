$jsonObject = Get-Content -Path "D:\Buhler\Task3\tv_shows_and_movies_sample.json" -Raw | ConvertFrom-Json
$csvObject = Import-Csv -Path "D:\Buhler\Task3\movies.csv"

foreach($object in $jsonObject){
$object.PSObject.Properties.Remove("scraped_at")
$imdbVotes = ($csvObject | Where-Object{$object.name.Trim() -eq $_.name.trim()}).imbd_votes
Add-Member -InputObject $object -MemberType NoteProperty -Name "imbd_votes" -Value $imdbVotes
}

$jsonObject | Export-Csv -Path "D:\Buhler\Task3\output.csv" -NoTypeInformation