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
. "$PSScriptRoot/utils/generateUniqueFiles.ps1"
. "$PSScriptRoot/utils/generateDuplicates.ps1"

# Define the root path for the file tree, please ensure this directory exists or change it to an existing one.
# Warning: Any existing files in the root path will be deleted.
$rootPath = "..\test\case\tree\"

# Delete existing files and folders in the root path
if (Test-Path $rootPath) {
  Remove-Item -Path $rootPath -Recurse -Force
}

# Recreate the root directory
New-Item -Path $rootPath -ItemType Directory | Out-Null

# Create the directory structure up to level 6
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
  $fullPath = Join-Path -Path $rootPath -ChildPath $dir
  New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
}

# Function to recursively create files with a probability
function Create-FilesRecursively {
  param (
      [string]$dirPath,
      [hashtable]$fileCounts,
      [int]$maxFilesPerType = 10,
      [int]$probability = 50
  )

  $fileTypes = @(
      @{Extension = ".csv"; ContentFunction = "Generate-CsvContent"},
      @{Extension = ".sql"; ContentFunction = "Generate-SqlContent"},
      @{Extension = ".xml"; ContentFunction = "Generate-XmlContent"},
      @{Extension = ".txt"; ContentFunction = "Generate-TextContent"},
      @{Extension = ".yml"; ContentFunction = "Generate-TextContent"}
  )

  foreach ($fileType in $fileTypes) {
      $fileKey = $fileType.Extension
      if (-not $fileCounts.ContainsKey($fileKey)) {
          $fileCounts[$fileKey] = 0
      }

      while ($fileCounts[$fileKey] -lt $maxFilesPerType) {
          if ((Get-Random -Maximum 100) -lt $probability) {
              $fileName = "File$(Get-RandomString 5)$($fileType.Extension)"
              $filePath = Join-Path -Path $dirPath -ChildPath $fileName
              & $fileType.ContentFunction $filePath
              $fileCounts[$fileKey]++
          } else {
              break
          }
      }
  }

  # Recursively create files in subdirectories
  $subDirs = Get-ChildItem -Path $dirPath -Directory
  foreach ($subDir in $subDirs) {
      Create-FilesRecursively -dirPath $subDir.FullName -fileCounts $fileCounts -maxFilesPerType $maxFilesPerType -probability $probability
  }
}

# Function to ensure there are at least 4 groups of duplicates
function Ensure-Duplicates {
  param (
      [string]$rootPath,
      [hashtable]$fileCounts,
      [int]$minGroups = 4,
      [int]$minDuplicatesPerGroup = 2,
      [int]$maxDuplicatesPerGroup = 6
  )

  $fileTypes = @(
      @{Extension = ".csv"; ContentFunction = "Generate-CsvContent"},
      @{Extension = ".sql"; ContentFunction = "Generate-SqlContent"},
      @{Extension = ".xml"; ContentFunction = "Generate-XmlContent"},
      @{Extension = ".txt"; ContentFunction = "Generate-TextContent"},
      @{Extension = ".yml"; ContentFunction = "Generate-TextContent"}
  )

  $directories = Get-ChildItem -Path $rootPath -Recurse -Directory
  $duplicateGroups = 0

  while ($duplicateGroups -lt $minGroups) {
      foreach ($fileType in $fileTypes) {
          if ($duplicateGroups -ge $minGroups) {
              break
          }

          $numDuplicates = Get-Random -Minimum $minDuplicatesPerGroup -Maximum $maxDuplicatesPerGroup
          $fileName = "duplicates$(Get-RandomString 5)$($fileType.Extension)"
          $sourceDir = $directories | Get-Random
          $sourcePath = Join-Path -Path $sourceDir.FullName -ChildPath $fileName

          if (-not (Test-Path $sourcePath)) {
              & $fileType.ContentFunction $sourcePath
              $fileCounts[$fileType.Extension]++

              for ($i = 1; $i -lt $numDuplicates; $i++) {
                  $targetDir = $directories | Get-Random
                  $targetPath = Join-Path -Path $targetDir.FullName -ChildPath $fileName

                  if (-not (Test-Path $targetPath)) {
                      Copy-Item -Path $sourcePath -Destination $targetPath
                      $fileCounts[$fileType.Extension]++
                  } else {
                      $i--  # Retry if target path already exists
                  }
              }

              $duplicateGroups++
          }
      }
  }
}

# Initialize file count hashtable
$fileCounts = @{}

# Create unique files recursively in the root directory and subdirectories
Create-FilesRecursively -dirPath $rootPath -fileCounts $fileCounts

# Ensure there are unique files in each directory
foreach ($dir in $directories) {
  $fullPath = Join-Path -Path $rootPath -ChildPath $dir
  Generate-UniqueFiles -dirPath $fullPath -fileCounts $fileCounts
}

# Ensure there are at least 4 groups of duplicates
Ensure-Duplicates -rootPath $rootPath -fileCounts $fileCounts

Write-Output "File structure created under $rootPath with unique and duplicate files"
