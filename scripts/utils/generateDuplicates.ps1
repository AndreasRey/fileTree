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
