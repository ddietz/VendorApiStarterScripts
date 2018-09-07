Param(
  [bool]$test = $False
)

Clear-Host

.\scripts\GetPurchaseOrdersFromEdiApi.ps1 `
    -configPrefix "purchaseOrders" `
    -ediApiEndpoint "purchase-orders" `
    -logPrefix "GetPurchaseOrdersLog_" `
    -readableName "get purchase orders" `
    -test $test
