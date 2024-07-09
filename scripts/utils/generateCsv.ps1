function Generate-CsvContent {
  param (
      [string]$filePath
  )
  $content = "ID,Name,Value,Date`n"
  for ($i = 1; $i -le 50; $i++) {
      $content += "$i,Item$(Get-Random -Maximum 100),$(Get-Random -Maximum 1000),$(Get-Random -Minimum 2020 -Maximum 2024)-$(Get-Random -Minimum 1 -Maximum 12)-$(Get-Random -Minimum 1 -Maximum 28)`n"
  }
  Set-Content -Path $filePath -Value $content
}
