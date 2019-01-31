.\GetPurchaseOrders.ps1 -test $true
.\SendOrderAcknowledgements.ps1 -test $true
.\SendShippingNotices -test $true
.\SendInvoices -test $true -orderId 17510373
.\SendCreditMemo.ps1 -test $true -orderId 17510373
