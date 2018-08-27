Param(
  [bool]$test = $False
)

Clear-Host

.\scripts\SendDocumentsToEdiApi.ps1 `
    -configPrefix "shippingNotice" `
    -ediApiEndpoint "shipping-notices" `
    -logPrefix "SendShippingNoticesLog_" `
    -readableName "send shipping notices" `
    -test $test
