$(document).ready ->
  if $('#received-transfer-items').length > 0
    Spree.StockTransfers.ReceiveVariantForm.initializeForm()
    Spree.StockTransfers.ReceiveVariantForm.beginListening()
    Spree.StockTransfers.ReceiveUpdateForms.beginListening()
