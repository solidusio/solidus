$(document).ready ->
  if $('#received-transfer-items').length > 0
    Spree.StockTransfers.VariantForm.initializeForm(false)
    Spree.StockTransfers.VariantForm.beginListeningForReceive()
    Spree.StockTransfers.CountUpdateForms.beginListening(true)
