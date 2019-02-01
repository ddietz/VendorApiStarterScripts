Param(
  [bool]$test = $False,
  [int]$orderId = -1
)

.\scripts\SendDocumentsToEdiApi.ps1 `
    -configPrefix "purchaseOrderChange" `
    -ediApiEndpoint "changes" `
    -logPrefix "SendPurcahseOrderChangeLog_" `
    -readableName "send purchase order change" `
    -ediApiEndpointPrefix "purchase-orders" `
    -orderId $orderId `
    -test $test
