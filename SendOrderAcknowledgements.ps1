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
If(!(Test-Path $config.acknowledgementsFailedPath)) { New-Item $config.acknowledgementsFailedPath -type directory }

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
            $file = $_;
            Add-LogEntry "Processing file $($file.FullName)..."
            try {
                $body = Get-Content -Raw -Path $file.FullName
                $data = $body | ConvertFrom-Json
                $url = "$($config.posAPIUri)edi/orders/$($data.orderId)/acknowledgements"

                $result = Invoke-RestMethod -Method Post -Uri $url -Body $body -Headers $headers
                if ($config.debug) { Add-LogEntry "Got result: $(ConvertTo-Json $result)" }

                if ($test -eq $false) {
                    $destination = [System.IO.Path]::Combine($config.acknowledgementsHistoryPath, $file.Name)
                    Move-Item -Force -Path $file.FullName -Destination $destination
                    Add-LogEntry "Moved $($file.Name) to $destination"
                }
            }
            catch {
                $destination = [System.IO.Path]::Combine($config.acknowledgementsFailedPath, $file.Name)
                Move-Item -Force -Path $file.FullName -Destination $destination
                $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
                $errResp = $streamReader.ReadToEnd() | ConvertFrom-Json
                $streamReader.Close()
                Add-LogEntry "Failed to send order acknowledgement. $($_.Exception.Message) $errResp"
            }
        }
    }
}
catch {
    Add-LogEntry "Send order acknowledgements error on line $($_.Exception.ScriptLineNumber): $($_.Exception.Message)"
    throw $_.Exception
}
