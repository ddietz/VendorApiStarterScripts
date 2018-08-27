Param(
  [bool]$test = $False
)

Clear-Host

.\scripts\SendDocumentsToEdiApi.ps1 `
    -configPrefix "acknowledgements" `
    -ediApiEndpoint "acknowledgements" `
    -logPrefix "SendOrderAcknowledgementsLog_" `
    -readableName "send order acknowledgements" `
    -test $test
