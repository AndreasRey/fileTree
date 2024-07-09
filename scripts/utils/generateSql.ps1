function Generate-SqlContent {
  param (
      [string]$filePath
  )
  $content = "CREATE TABLE RandomTable (ID INT, Name VARCHAR(100), Value DECIMAL, Date DATE);`n"
  for ($i = 1; $i -le 50; $i++) {
      $content += "INSERT INTO RandomTable VALUES ($i, 'Item$(Get-Random -Maximum 100)', $(Get-Random -Maximum 1000), '$(Get-Random -Minimum 2020 -Maximum 2024)-$(Get-Random -Minimum 1 -Maximum 12)-$(Get-Random -Minimum 1 -Maximum 28)');`n"
  }
  Set-Content -Path $filePath -Value $content
}
