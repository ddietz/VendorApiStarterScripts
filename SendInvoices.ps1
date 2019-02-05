Param(
  [bool]$test = $False
)

.\scripts\SendDocumentsToEdiApi.ps1 `
    -configPrefix "invoice" `
    -ediApiEndpoint "invoices" `
    -logPrefix "SendInvoicesLog_" `
    -readableName "send invoices" `
    -test $test
