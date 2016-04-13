$(document).ready ->
  if $('#stock-transfer-transfer-items').length > 0
    Spree.StockTransfers.VariantForm.initializeForm(true)
    Spree.StockTransfers.VariantForm.beginListeningForAdd()
    Spree.StockTransfers.CountUpdateForms.beginListening(false)
    Spree.StockTransfers.TransferItemDeleting.beginListening()
