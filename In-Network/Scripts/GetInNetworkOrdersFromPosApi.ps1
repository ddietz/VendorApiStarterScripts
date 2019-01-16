Param(
  [string]$configPrefix,
  [string]$posApiEndpoint,
  [string]$logPrefix,
  [string]$readableName,
  [bool]$test = $false
)

# Read in configuration file
$config = Get-Content -Raw -Path "config.json" | ConvertFrom-Json

# Create simplified variables
$unconfirmedPath = $config.$($configPrefix + "UnconfirmedPath")
$confirmedPath = $config.$($configPrefix + "ConfirmedPath")
$ordersGetCount = $config.$($configPrefix + "GetCount")
$ordersGetPending = $config.$($configPrefix + "GetPending")

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
            $uri = "$($config.posAPIUri)$($posApiEndpoint)?pending=$($ordersGetPending)&count=$($ordersGetCount)"
            $message = "Accessing API: " + $uri
            Add-LogEntry $message

            $result = Invoke-RestMethod -Method GET -URI $uri -Header $header
            $message = "Number of orders retrieved - " + $result.items.length
            Add-LogEntry $message

            #When testing, remember the first orderId in global scope
            if ($test -eq $true -And $result.items.length -gt 0){
                $global:inNetworkOrderIdForTest = $result.items[0].header.orderID;
                Add-LogEntry "Set global:inNetworkOrderIdForTest to $global:inNetworkOrderIdForTest"
            }

            #Save each order to disk to the Unconfirmed Path
            ForEach ($order In $result.items){
                $unconfirmedPathFile = $unconfirmedPath + "\" + $order.header.orderId + ".json"
                $confirmedPathFile = $confirmedPath + "\" + $order.header.orderId + ".json"
                if($ordersGetPending){
                    $message = "Saving Order in JSON format $($unconfirmedPathFile)"
                    Add-LogEntry $message
                        $order | ConvertTo-Json | Out-File $unconfirmedPathFile -ErrorAction Stop
                    .\scripts\ConfirmOrderReceipt.ps1 `
                        -configPrefix "orders" `
                        -logPrefix "GetInNetworkOrdersLog_" `
                        -readableName "confirm in-network orders" `
                        -orderId $order.header.orderId `
                        -unconfirmedPathFile $unconfirmedPathFile `
                        -confirmedPathFile $confirmedPathFile `
                        -accessToken $accessToken `
                        -test $test `
                }
                else{
                    $message = "Saving Order in JSON format $($confirmedPathFile)"
                    Add-LogEntry $message
                        $order | ConvertTo-Json | Out-File $confirmedPathFile -ErrorAction Stop
                }
            }
            #this would display the orders to the console
            #Return $result.items
        }
        Catch{
            $message = "GetInNetworkOrdersFromPosApi Error Message: " + $_.Exception.Message
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
