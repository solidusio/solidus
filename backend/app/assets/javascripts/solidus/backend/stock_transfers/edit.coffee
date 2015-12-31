$(document).ready ->
  if $('#stock-transfer-transfer-items').length > 0
    Solidus.StockTransfers.VariantForm.initializeForm(true)
    Solidus.StockTransfers.VariantForm.beginListeningForAdd()
    Solidus.StockTransfers.CountUpdateForms.beginListening(false)
    Solidus.StockTransfers.TransferItemDeleting.beginListening()

    $("#ready-to-ship-transfer-button").on('click', (ev) ->
      ev.preventDefault()
      $('#finalize-stock-transfer-warning').show()
    )

    $("#cancel-finalize-link").on('click', (ev) ->
      ev.preventDefault()
      $('#finalize-stock-transfer-warning').hide()
    )
