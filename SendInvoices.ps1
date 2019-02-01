Param(
  [bool]$test = $False,
  [int]$orderId = -1
)

.\scripts\SendDocumentsToEdiApi.ps1 `
    -configPrefix "invoice" `
    -ediApiEndpoint "invoices" `
    -logPrefix "SendInvoicesLog_" `
    -readableName "send invoices" `
    -orderId $orderId `
    -test $test
