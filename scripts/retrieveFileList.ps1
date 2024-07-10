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
    $owner = (Get-Acl $item.FullName).Owner
    $parentFolderFull = Split-Path -Path $item.FullName -Parent
    $parentFolderName = Split-Path -Path $parentFolderFull -Leaf    
    $itemDetail = [PSCustomObject]@{
        FullName          = $item.FullName
        Name              = $item.Name
        parentfolderfull  = $parentFolderFull
        parentfoldername  = $parentFolderName        
        Extension         = $extension
        Size              = if ($item.PSIsContainer) { 0 } else { $item.Length }
        Type              = $type
        Level             = $level
        CreationTime      = $item.CreationTime
        LastWriteTime     = $item.LastWriteTime
        LastAccessTime    = $item.LastAccessTime
        Attributes        = $item.Attributes
        Owner             = $owner
        Access            = (Get-Acl $item.FullName).Access
        Group             = (Get-Acl $item.FullName).Group
        Mode              = $item.Mode
        IsReadOnly        = $item.IsReadOnly
        IsHidden          = $item.Attributes -match "Hidden"
        IsSystem          = $item.Attributes -match "System"
        IsArchive         = $item.Attributes -match "Archive"
    }
    $itemDetails += $itemDetail
}

# Convert the item details array to a CSV format and save it
$itemDetails | Export-Csv -Path $outputCsv -NoTypeInformation -Encoding UTF8

Write-Output "Item details written to $outputCsv"
