# Define the folder path to scan
$folderPath = "../../test/case/tree/"

# Define the output file name and location
$outputFileName = "File_Details.csv"
$outputFilePath = ".\out\"  # Ensure this directory exists or change it to an existing one

# Create the full output file path
$fullOutputFilePath = Join-Path -Path $outputFilePath -ChildPath $outputFileName

# Ensure the output directory exists
if (-not (Test-Path $outputFilePath)) {
    New-Item -Path $outputFilePath -ItemType Directory | Out-Null
}

# Get all files and directories in the folder recursively
$items = Get-ChildItem -Path $folderPath -Recurse

# Function to get file owner
function Get-FileOwner {
    param (
        [string]$filePath
    )
    $owner = (Get-Acl -Path $filePath).Owner
    return $owner
}

# Function to calculate the level based on the number of backslashes in the full path
function Get-Level {
    param (
        [string]$filePath
    )
    return ($filePath -split '\\').Length - 1
}

# Initialize an array to store file details
$fileDetails = @()

# Process each item (file or directory)
foreach ($item in $items) {
    if ($item.PSIsContainer) {
        # Item is a directory, check if it's empty
        $subItems = Get-ChildItem -Path $item.FullName
        $isEmpty = ($subItems.Count -eq 0)

        if ($isEmpty) {
            # Add details for the empty directory
            $fileDetails += [pscustomobject]@{
                "Full Path"         = $item.FullName
                "File Name"         = $item.Name
                "File Extension"    = ""
                "File Size (Bytes)" = ""
                "Creation Date"     = $item.CreationTime
                "Last Modified Date"= $item.LastWriteTime
                "File Owner"        = Get-FileOwner $item.FullName
                "Level"             = Get-Level $item.FullName
            }
        }
    } else {
        # Item is a file, add file details
        $fileDetails += [pscustomobject]@{
            "Full Path"         = $item.FullName
            "File Name"         = $item.Name
            "File Extension"    = $item.Extension
            "File Size (Bytes)" = $item.Length
            "Creation Date"     = $item.CreationTime
            "Last Modified Date"= $item.LastWriteTime
            "File Owner"        = Get-FileOwner $item.FullName
            "Level"             = Get-Level $item.FullName
        }
    }
}

# Export the details to CSV
$fileDetails | Export-Csv -Path $fullOutputFilePath -NoTypeInformation

# Output completion
Write-Output "File details exported to $fullOutputFilePath"
