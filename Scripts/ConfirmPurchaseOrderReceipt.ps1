Param(
  [string]$configPrefix,
  [string]$logPrefix,
  [string]$readableName,
  [string]$orderId,
  [string]$unconfirmedPathFile,
  [string]$confirmedPathFile,
  [string]$accessToken,
  [bool]$test = $false
)

# Read in configuration file
$config = Get-Content -Raw -Path "config.json" | ConvertFrom-Json

# Simplified logging
function Add-LogEntry([string]$message) {
    Add-Content $logFile $message
    if ($config.outputToConsole) { Write-Host $message }
}

# Open log
$logFile = "$($config.logFile)$logPrefix$(Get-Date -Format ""yyyy-MM-dd"").txt"
Add-LogEntry "Start of $readableName script - $(Get-Date -Format ""u"")"

# Confirm the purchase order
try {
    $message = "Confirming purchase order: $($unconfirmedPathFile)"
    Add-LogEntry $message

    #Get Orders From API
    Try{
        $uri = "$($config.posAPIUri)purchase-orders/$($orderId)/receipts"
        $message = "Accessing API: " + $uri
        Add-LogEntry $message

        $result = Invoke-RestMethod -Method PUT -URI $uri -Header $header
        $message = "Order $($orderId) confirmed"
        Add-LogEntry $message

        $message = "Moving Order $($orderId) file to $($confirmedPathFile)"
        Add-LogEntry $message
        Move-Item  -Force -Path $unconfirmedPathFile -Destination $confirmedPathFile
    }
    Catch{
        $message = "GetPuchaseOrdersFromEdiAPI Error Message: " + $_.Exception.Message
        Add-LogEntry $message
        $message = "Error occurred in line " +  $_.InvocationInfo.ScriptLineNumber
        Add-LogEntry $message
        Throw $_.Exception
    }
}
catch {
    Add-LogEntry "Error for $readableName on line $($_.Exception.ScriptLineNumber): $($_.Exception.Message)"
    throw $_.Exception
}
