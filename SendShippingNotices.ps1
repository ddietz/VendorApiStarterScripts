Param(
  [bool]$test = $false
)

Clear-Host

# Read in configuration file
$config = Get-Content -Raw -Path "config.json" | ConvertFrom-Json

# Create folders if they do not exist
If(!(Test-Path $config.logFile)) { New-Item $config.logFile -type directory }
If(!(Test-Path $config.shippingNoticeJsonPath)) { New-Item $config.shippingNoticeJsonPath -type directory }
If(!(Test-Path $config.shippingNoticeHistoryPath)) { New-Item $config.shippingNoticeHistoryPath -type directory }
If(!(Test-Path $config.shippingNoticeFailedPath)) { New-Item $config.shippingNoticeFailedPath -type directory }

# Simplified logging
function Add-LogEntry([string]$message) {
    Add-Content $logFile $message
    if ($config.outputToConsole) { Write-Host $message }
}

# Open log
$logFile = "$($config.logFile)SendShippingNoticesLog_$(Get-Date -Format ""yyyy-MM-dd"").txt"
Add-LogEntry "Start of send shipping notices script - $(Get-Date -Format ""u"")"

# Read in shipping notices
try {
    $accessToken = .\scripts\GetAccessToken.ps1 $config.clientSecret $config.identityAPIUri  $config.clientId $logFile $config.debug
    if ($accessToken) {
        # Configure API access
        $headers = @{"Authorization" = "Bearer $accessToken"; "Accept" = "application/json"; "Content-Type" = "application/json"}

        # Iterate over each file
        Get-ChildItem -File $config.shippingNoticeJsonPath | ForEach-Object {
            $file = $_;
            Add-LogEntry "Processing file $($file.FullName)..."
            try {
                $body = Get-Content -Raw -Path $file.FullName
                $data = $body | ConvertFrom-Json
                $url = "$($config.posAPIUri)edi/orders/$($data.orderId)/shipping-notices"

                $result = Invoke-RestMethod -Method Post -Uri $url -Body $body -Headers $headers
                if ($config.debug) { Add-LogEntry "Got result: $(ConvertTo-Json $result)" }

                if ($test -eq $false) {
                    $destination = [System.IO.Path]::Combine($config.shippingNoticeHistoryPath, $file.Name)
                    Move-Item -Force -Path $file.FullName -Destination $destination
                    Add-LogEntry "Moved $($file.Name) to $destination"
                }
            }
            catch {
                $destination = [System.IO.Path]::Combine($config.shippingNoticeFailedPath, $file.Name)
                Move-Item -Force -Path $file.FullName -Destination $destination
                $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
                $errResp = $streamReader.ReadToEnd() | ConvertFrom-Json
                $streamReader.Close()
                Add-LogEntry "Failed to send shipping notice. $($_.Exception.Message)"
            }
        }
    }
}
catch {
    Add-LogEntry "Send shipping notices error on line $($_.Exception.ScriptLineNumber): $($_.Exception.Message)"
    throw $_.Exception
}
