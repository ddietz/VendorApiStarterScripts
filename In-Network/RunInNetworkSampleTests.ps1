$global:orderIdForTest = -1
.\GetInNetworkOrders.ps1 -test $true
.\SendInNetworkInvoices.ps1 -test $true
.\SendInNetworkShippingNotices.ps1 -test $true
