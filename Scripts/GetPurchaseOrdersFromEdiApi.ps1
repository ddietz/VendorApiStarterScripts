Param(
  [string]$configPrefix,
  [string]$ediApiEndpoint,
  [string]$logPrefix,
  [string]$readableName,
  [bool]$test = $false
)

# Read in configuration file
$config = Get-Content -Raw -Path "config.json" | ConvertFrom-Json

# Create simplified variables
$unconfirmedPath = $config.$($configPrefix + "UnconfirmedPath")
$confirmedPath = $config.$($configPrefix + "ConfirmedPath")

# Create folders if they do not exist
If(!(Test-Path $config.logFile)) { New-Item $config.logFile -type directory }
If(!(Test-Path $unconfirmedPath)) { New-Item $unconfirmedPath -type directory }
If(!(Test-Path $confirmedPath)) { New-Item $confirmedPath -type directory }

# Simplified logging
function Add-LogEntry([string]$message) {
    Add-Content $logFile $message
    if ($config.outputToConsole) { Write-Host $message }
}

# Open log
$logFile = "$($config.logFile)$logPrefix$(Get-Date -Format ""yyyy-MM-dd"").txt"
Add-LogEntry "Start of $readableName script - $(Get-Date -Format ""u"")"

# Download purchase orders to disk
try {
    $accessToken = .\scripts\GetAccessToken.ps1 $config.clientSecret $config.identityAPIUri  $config.clientId $logFile $config.debug
    if ($accessToken) {
        Add-LogEntry $accessToken
        # Configure API access
        $header = @{"Authorization" = "Bearer $accessToken"; "Accept" = "application/json"; "Content-Type" = "application/json"}

        #Get Orders From API
        Try{
            $uri = "$($config.posAPIUri)$($ediApiEndpoint)?confirmed=false&count=2"
            $message = "Accessing API: " + $uri
            Add-LogEntry $message

            $result = Invoke-RestMethod -Method GET -URI $uri -Header $header
            $message = "Number of orders retrieved - " + $result.items.length
            Add-LogEntry $message

            #Save each order to disk to the Unconfirmed Path
            ForEach ($order In $result.items){
                $orderId = $order.geniusCentral.documentId
                $pathFile = $unconfirmedPath + "\$($orderId).json"
                $confirmedPathFile = $confirmedPath + "\$($orderId).json"
                $message = "Saving Order $($orderId) in JSON format $($pathFile)"
                Add-LogEntry $message
                $order | ConvertTo-Json | Out-File $pathFile -ErrorAction Stop
                .\scripts\ConfirmPurchaseOrderReceipt.ps1 `
                    -configPrefix "purchaseOrders" `
                    -logPrefix "GetPurchaseOrdersLog_" `
                    -readableName "confirm purchase orders" `
                    -orderId $orderId `
                    -unconfirmedPathFile $pathFile `
                    -confirmedPathFile $confirmedPathFile `
                    -accessToken $accessToken `
                    -test $test `
            }

            #this would display the orders to the console
            #Return $result.items
        }
        Catch{
            $message = "GetPuchaseOrdersFromEdiAPI Error Message: " + $_.Exception.Message
            Add-LogEntry $message
            $message = "Error occurred in line " +  $_.InvocationInfo.ScriptLineNumber
            Add-LogEntry $message
            Throw $_.Exception
        }
    }
}
catch {
    Add-LogEntry "Error for $readableName on line $($_.Exception.ScriptLineNumber): $($_.Exception.Message)"
    throw $_.Exception
}
