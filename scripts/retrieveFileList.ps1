# Define the folder path to scan
$folderPath = "C:\Users\abc_0\Documents\Temp"

# Define the output file name and location
$outputFileName = "File_Details.csv"
$outputFilePath = ".\out\"  # Ensure this directory exists or change it to an existing one

# Ensure the output directory exists
if (-not (Test-Path $outputFilePath)) {
    New-Item -Path $outputFilePath -ItemType Directory | Out-Null
}

# Define the output CSV file
$outputCsv = Join-Path -Path $outputFilePath -ChildPath $outputFileName

# Get a list of all files and folders in the folder and subfolders
$items = Get-ChildItem -Path $folderPath -Recurse

# Create an array to store item details
$itemDetails = @()

foreach ($item in $items) {
    $type = if ($item.PSIsContainer) { "folder" } else { "file" }
    $extension = if ($item.PSIsContainer) { "" } else { $item.Extension }
    $level = ($item.FullName -replace [regex]::Escape($folderPath), "").Split([io.path]::DirectorySeparatorChar).Count - 1
    $itemDetail = [PSCustomObject]@{
        fullpath          = $item.FullName
        name              = $item.Name
        extension         = $extension
        size              = if ($item.PSIsContainer) { 0 } else { $item.Length }
        type              = $type
        level             = $level
        creation_date     = $item.CreationTime
        modification_date = $item.LastWriteTime
        created_by        = $null # Placeholder for created by
        last_edited_by    = $null # Placeholder for last edited by
    }
    $itemDetails += $itemDetail
}

# Convert the item details array to a CSV format and save it
$itemDetails | Export-Csv -Path $outputCsv -NoTypeInformation -Encoding UTF8

Write-Output "Item details written to $outputCsv"
