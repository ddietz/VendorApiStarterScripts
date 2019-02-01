Param(
  [bool]$test = $False
)

.\scripts\GetPurchaseOrdersFromEdiApi.ps1 `
    -configPrefix "purchaseOrders" `
    -ediApiEndpoint "v2/purchase-orders" `
    -logPrefix "GetPurchaseOrdersLog_" `
    -readableName "get purchase orders" `
    -test $test
