Param(
  [bool]$test = $False
)

.\scripts\SendDocumentsToPosApi.ps1 `
    -configPrefix "invoice" `
    -posApiEndpoint "in-network/invoices" `
    -logPrefix "SendInvoicesLog_" `
    -readableName "send invoices" `
    -test $test
