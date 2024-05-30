$csvFile = "D:\Buhler\Task2\goodreads_cleaned.csv"
$position = 0
Import-Csv -Path $csvFile | Format-List -Property bookTitle, average_rating, @{Name="Position"; Expression={$script:position++; $script:position}}