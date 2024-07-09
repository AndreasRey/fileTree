function Generate-XmlContent {
  param (
      [string]$filePath
  )
  $content = "<root>`n"
  for ($i = 1; $i -le 50; $i++) {
      $content += "  <record>`n    <ID>$i</ID>`n    <Name>Item$(Get-Random -Maximum 100)</Name>`n    <Value>$(Get-Random -Maximum 1000)</Value>`n    <Date>$(Get-Random -Minimum 2020 -Maximum 2024)-$(Get-Random -Minimum 1 -Maximum 12)-$(Get-Random -Minimum 1 -Maximum 28)</Date>`n  </record>`n"
  }
  $content += "</root>"
  Set-Content -Path $filePath -Value $content
}
