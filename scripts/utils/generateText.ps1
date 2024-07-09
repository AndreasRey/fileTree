function Generate-TextContent {
  param (
      [string]$filePath
  )
  $content = ""
  for ($i = 1; $i -le 50; $i++) {
      $content += "$(Get-RandomString 10) $(Get-RandomString 15) $(Get-RandomString 20)`n"
  }
  Set-Content -Path $filePath -Value $content
}
