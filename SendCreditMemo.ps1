Param(
  [bool]$test = $False
)

.\scripts\SendDocumentsToEdiApi.ps1 `
    -configPrefix "creditMemo" `
    -ediApiEndpoint "credit-adjustments" `
    -logPrefix "SendCreditMemosLog_" `
    -readableName "send credit memos" `
    -ediApiEndpointPrefix "purchase-orders" `
    -test $test
