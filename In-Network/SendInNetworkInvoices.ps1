Param(
  [bool]$test = $False
)

Clear-Host

.\scripts\SendDocumentsToPosApi.ps1 `
    -configPrefix "invoice" `
    -posApiEndpoint "in-network/invoices" `
    -logPrefix "SendInvoicesLog_" `
    -readableName "send invoices" `
    -test $test
