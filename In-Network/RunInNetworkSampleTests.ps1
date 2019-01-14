$global:orderIdForTest = -1
.\GetInNetworkOrders.ps1 -test $true
# .\SendOrderAcknowledgements.ps1 -test $true
# .\SendShippingNotices -test $true
# .\SendInvoices -test $true
# .\SendCreditMemo.ps1 -test $true -orderId $global:orderIdForTest
