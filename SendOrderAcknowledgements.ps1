Param(
  [bool]$test = $false
)

Clear-Host

# Read in configuration file
$config = Get-Content -Raw -Path "config.json" | ConvertFrom-Json

# Create folders if they do not exist
If(!(Test-Path $config.logFile)) { New-Item $config.logFile -type directory }
If(!(Test-Path $config.acknowledgementsJsonPath)) { New-Item $config.acknowledgementsJsonPath -type directory }
If(!(Test-Path $config.acknowledgementsHistoryPath)) { New-Item $config.acknowledgementsHistoryPath -type directory }

# Simplified logging
function Add-LogEntry([string]$message) {
    Add-Content $logFile $message
    if ($config.outputToConsole) { Write-Host $message }
}

# Open log
$logFile = "$($config.logFile)SendOrderAcknowledgementsLog_$(Get-Date -Format ""yyyy-MM-dd"").txt"
Add-LogEntry "Start of send order acknowledgements script - $(Get-Date -Format ""u"")"

# Read in order acknowledgements
try {
    $accessToken = .\scripts\GetAccessToken.ps1 $config.clientSecret $config.identityAPIUri  $config.clientId $logFile $config.debug
    if ($accessToken) {
        # Configure API access
        $headers = @{"Authorization" = "Bearer $accessToken"; "Accept" = "application/json"; "Content-Type" = "application/json"}

        # Iterate over each file
        Get-ChildItem -File $config.acknowledgementsJsonPath | ForEach-Object {
            Add-LogEntry "Processing file $($_.FullName)..."
            try {
                $body = Get-Content -Raw -Path $_.FullName
                $data = $body | ConvertFrom-Json
                $url = "$($config.posAPIUri)edi/orders/$($data.orderId)/acknowledgements"

                $result = Invoke-RestMethod -Method Post -Uri $url -Body $body -Headers $headers
                if ($config.debug) { Add-LogEntry "Got result: $(ConvertTo-Json $result)" }

                if ($test -eq $false) {
                    $destination = [System.IO.Path]::Combine($config.acknowledgementsHistoryPath, $_.Name)
                    Move-Item -Force -Path $_.FullName -Destination $destination
                    Add-LogEntry "Moved $($_.Name) to $destination"
                }
            }
            catch {
                Add-LogEntry "Failed to send order acknowledgement. $($_.Exception.Message)"
            }
        }
    }
}
catch {
    Add-LogEntry "Send order acknowledgements error on line $($_.Exception.ScriptLineNumber): $($_.Exception.Message)"
    throw $_.Exception
}
