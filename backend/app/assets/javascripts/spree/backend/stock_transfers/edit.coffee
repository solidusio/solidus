$(document).ready ->
  if $('#stock-transfer-transfer-items').length > 0
    Spree.StockTransfers.VariantForm.initializeForm()
    Spree.StockTransfers.VariantForm.beginListeningForAdd()
    Spree.StockTransfers.CountUpdateForms.beginListening(false)
    Spree.StockTransfers.TransferItemDeleting.beginListening()

    $("#ready-to-ship-transfer-button").on('click', (ev) ->
      ev.preventDefault()
      $('#finalize-stock-transfer-warning').show()
    )

    $("#cancel-finalize-link").on('click', (ev) ->
      ev.preventDefault()
      $('#finalize-stock-transfer-warning').hide()
    )
