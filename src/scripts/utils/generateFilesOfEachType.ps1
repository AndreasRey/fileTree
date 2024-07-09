function Generate-FilesOfEachType {
  param (
      [string]$dirPath,
      [int]$minFiles = 1,
      [int]$maxFiles = 5
  )

  $fileTypes = @(
      @{Extension = ".csv"; ContentFunction = "Generate-CsvContent"},
      @{Extension = ".sql"; ContentFunction = "Generate-SqlContent"},
      @{Extension = ".xml"; ContentFunction = "Generate-XmlContent"},
      @{Extension = ".txt"; ContentFunction = "Generate-TextContent"},
      @{Extension = ".yml"; ContentFunction = "Generate-TextContent"}
  )

  foreach ($fileType in $fileTypes) {
      $numFiles = Get-Random -Minimum $minFiles -Maximum $maxFiles
      for ($i = 1; $i -le $numFiles; $i++) {
          $fileName = "File$(Get-RandomString 5)$($fileType.Extension)"
          $filePath = Join-Path -Path $dirPath -ChildPath $fileName
          & $fileType.ContentFunction $filePath
      }
  }
}
