# Define the helper function to create a random string
function Get-RandomString {
  param (
      [int]$length
  )
  -join ((65..90) + (97..122) | Get-Random -Count $length | % {[char]$_})
}

# Load utility functions
. "$PSScriptRoot/utils/generateCsv.ps1"
. "$PSScriptRoot/utils/generateSql.ps1"
. "$PSScriptRoot/utils/generateXml.ps1"
. "$PSScriptRoot/utils/generateText.ps1"
. "$PSScriptRoot/utils/generateFilesOfEachType.ps1"

# Define the root path for the file tree, please ensure this directory exists or change it to an existing one.
# Warning: Any existing files in the root path will be deleted.
$rootPath = "..\..\test\case\tree\"

# Delete existing files and folders in the root path
if (Test-Path $rootPath) {
  Remove-Item -Path $rootPath -Recurse -Force
}

# Recreate the root directory
New-Item -Path $rootPath -ItemType Directory | Out-Null

# Create the directory structure
$directories = @(
  "schema",
  "project/assets/asset_type/asset/step/publish",
  "project/assets/asset_type/asset/step/reference",
  "project/assets/asset_type/asset/step/review",
  "project/assets/asset_type/asset/step/work",
  "project/editorial",
  "project/reference",
  "project/sequences"
)

foreach ($dir in $directories) {
  New-Item -Path (Join-Path -Path $rootPath -ChildPath $dir) -ItemType Directory -Force | Out-Null
}

# Create the required number of files for each type in the root directory
Generate-FilesOfEachType -dirPath $rootPath

Write-Output "File structure created under $rootPath"
