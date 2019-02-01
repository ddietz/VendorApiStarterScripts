Param(
  [string]$configPrefix,
  [string]$ediApiEndpoint,
  [string]$ediApiEndpointPrefix = "orders",
  [string]$logPrefix,
  [string]$readableName,
  [int]$orderId = -1,
  [bool]$test = $false
)

# Read in configuration file
$config = Get-Content -Raw -Path "config.json" | ConvertFrom-Json

# Create simplified variables
$jsonPath = $config.$($configPrefix + "JsonPath")
$historyPath = $config.$($configPrefix + "HistoryPath")
$failedPath = $config.$($configPrefix + "FailedPath")

# Create folders if they do not exist
If(!(Test-Path $config.logFile)) { New-Item $config.logFile -type directory }
If(!(Test-Path $jsonPath)) { New-Item $jsonPath -type directory }
If(!(Test-Path $historyPath)) { New-Item $historyPath -type directory }
If(!(Test-Path $failedPath)) { New-Item $failedPath -type directory }

# Simplified logging
function Add-LogEntry([string]$message) {
    Add-Content $logFile $message
    if ($config.outputToConsole) { Write-Host $message }
}

# Open log
$logFile = "$($config.logFile)$logPrefix$(Get-Date -Format ""yyyy-MM-dd"").txt"
Add-LogEntry "Start of $readableName script - $(Get-Date -Format ""u"")"

Add-LogEntry "orderId [$($orderId)] test [$($test)] ediApiEndpoint [$($ediApiEndpoint)]"

# Read in documents
try {
    $accessToken = .\scripts\GetAccessToken.ps1 $config.clientSecret $config.identityAPIUri  $config.clientId $logFile $config.debug
    if ($accessToken) {
        # Configure API access
        $headers = @{"Authorization" = "Bearer $accessToken"; "Accept" = "application/json"; "Content-Type" = "application/json"}

        # Iterate over each file
        Get-ChildItem -File $jsonPath | ForEach-Object {
            $file = $_;
            Add-LogEntry "Processing file $($file.FullName)..."
            try {
                $body = Get-Content -Raw -Path $file.FullName
                $data = $body | ConvertFrom-Json

                if($orderId -ne -1 ){
                    $entityId = $orderId;
                    Add-LogEntry "EntityId source (1) orderId param: $entityId"
                }
                elseif($ediApiEndpointPrefix -eq "purchase-orders"){
                    $entityId = $data.buyer.purchaseOrderNumber;
                    Add-LogEntry "EntityId source (2) data file purchaseOrderNumber: $entityId"
                } else {
                    $entityId = $data.orderId;
                    Add-LogEntry "EntityId source (3) data file orderId: $entityId"
                }

                $url = "$($config.posAPIUri)$ediApiEndpointPrefix/$($entityId)/$ediApiEndpoint"

                Add-LogEntry "URL: $url"

                $result = Invoke-RestMethod -Method Post -Uri $url -Body $body -Headers $headers
                if ($config.debug) { Add-LogEntry "Got result: $(ConvertTo-Json $result)" }

                if ($test -eq $false) {
                    $destination = [System.IO.Path]::Combine($historyPath, $file.Name)
                    Move-Item -Force -Path $file.FullName -Destination $destination
                    Add-LogEntry "Moved $($file.Name) to $destination"
                }
            }
            catch {
                Add-LogEntry "Failed to $readableName. $($_.Exception.Message)"
                $destination = [System.IO.Path]::Combine($failedPath, $file.Name)
                if ($test -eq $false) {
                    Move-Item -Force -Path $file.FullName -Destination $destination
                }
                if($_.Exception.Response){
                    $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
                    $errResp = $streamReader.ReadToEnd() | ConvertFrom-Json
                    $streamReader.Close()
                    Add-LogEntry "Failure Response Stream $errResp"
                }
            }
        }
    }
}
catch {
    Add-LogEntry "Error for $readableName on line $($_.Exception.ScriptLineNumber): $($_.Exception.Message)"
    throw $_.Exception
}
