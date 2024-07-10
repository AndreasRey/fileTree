# Connect to SharePoint Online
# $siteUrl = "https://msfintl.sharepoint.com/:f:/r/sites/GRP-VIE-EO-WKSPC/Shared%20Documents/WKSPC/PROJECTS?csf=1&web=1&e=GiI37Y"
# $siteUrl = "https://msfintl.sharepoint.com/:f:/r/sites/GRP-VIE-EO-WKSPC/Shared%20Documents/WKSPC/PROJECTS?csf=1&web=1&e=YXYeTp"
$siteUrl = "https://msfintl.sharepoint.com/sites/GRP-VIE-EO-WKSPC/"
Connect-PnPOnline -Url $siteUrl -Interactive

# Define the library or folder path to scan
$libraryPath = "Shared%20Documents"

# Define the output file name and location
$outputFileName = "SharePoint_File_Details.csv"
$outputFilePath = ".\out\"  # Ensure this directory exists or change it to an existing one

# Ensure the output directory exists
if (-not (Test-Path $outputFilePath)) {
    New-Item -Path $outputFilePath -ItemType Directory | Out-Null
}

# Define the output CSV file
$outputCsv = Join-Path -Path $outputFilePath -ChildPath $outputFileName

# Get a list of all files and folders in the library
try {
    $items = Get-PnPListItem -List $libraryPath -PageSize 500 -Fields "FileLeafRef", "FileDirRef", "FSObjType", "File_x0020_Size", "Created", "Modified", "Author", "Editor"
} catch {
    Write-Host "Error retrieving list items: $_"
    exit
}

# Create an array to store item details
$itemDetails = @()

foreach ($item in $items) {
    $isFolder = $item["FSObjType"] -eq "1"
    $fullPath = $item["FileDirRef"] + "/" + $item["FileLeafRef"]
    $type = if ($isFolder) { "folder" } else { "file" }
    $extension = if ($isFolder) { "" } else { [System.IO.Path]::GetExtension($item["FileLeafRef"]) }
    $level = ($item["FileDirRef"] -replace [regex]::Escape($libraryPath), "").Split("/").Count
    $owner = $item["Author"].Email
    $lastEditedBy = $item["Editor"].Email
    $parentFolderFull = $item["FileDirRef"]
    $parentFolderName = Split-Path -Path $parentFolderFull -Leaf
    $size = if ($isFolder) { 0 } else { $item["File_x0020_Size"] }
    $itemDetail = [PSCustomObject]@{
        fullpath          = $fullPath
        name              = $item["FileLeafRef"]
        extension         = $extension
        size              = $size
        type              = $type
        level             = $level
        creation_time     = $item["Created"]
        last_write_time   = $item["Modified"]
        owner             = $owner
        last_edited_by    = $lastEditedBy
        parentfolderfull  = $parentFolderFull
        parentfoldername  = $parentFolderName
    }
    $itemDetails += $itemDetail
}

# Convert the item details array to a CSV format and save it
$itemDetails | Export-Csv -Path $outputCsv -NoTypeInformation -Encoding UTF8

Write-Output "Item details written to $outputCsv"