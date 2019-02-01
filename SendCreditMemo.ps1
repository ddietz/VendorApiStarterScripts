Param(
  [bool]$test = $False,
  [int]$orderId = -1
)

.\scripts\SendDocumentsToEdiApi.ps1 `
    -configPrefix "creditMemo" `
    -ediApiEndpoint "credit-adjustments" `
    -logPrefix "SendCreditMemosLog_" `
    -readableName "send credit memos" `
    -ediApiEndpointPrefix "purchase-orders" `
    -orderId $orderId `
    -test $test
