Param(
  [bool]$test = $False
)

Clear-Host

.\scripts\SendDocumentsToPosApi.ps1 `
    -configPrefix "shippingNotice" `
    -posApiEndpoint "in-network/shipping-notices" `
    -logPrefix "SendShippingNoticesLog_" `
    -readableName "send shipping notice" `
    -test $test
