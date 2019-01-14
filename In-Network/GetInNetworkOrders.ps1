Param(
  [bool]$test = $False
)

Clear-Host

.\scripts\GetInNetworkOrdersFromPosApi.ps1 `
    -configPrefix "orders" `
    -posApiEndpoint "in-network/orders" `
    -logPrefix "GetInNetworkOrdersLog_" `
    -readableName "get in-network orders" `
    -test $test
