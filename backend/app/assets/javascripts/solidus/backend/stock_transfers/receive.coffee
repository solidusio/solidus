$(document).ready ->
  if $('#received-transfer-items').length > 0
    Solidus.StockTransfers.VariantForm.initializeForm(false)
    Solidus.StockTransfers.VariantForm.beginListeningForReceive()
    Solidus.StockTransfers.CountUpdateForms.beginListening(true)

    $("#close-transfer-button").on('click', (ev) ->
      ev.preventDefault()
      $('#close-stock-transfer-warning').show()
    )

    $("#cancel-close-link").on('click', (ev) ->
      ev.preventDefault()
      $('#close-stock-transfer-warning').hide()
    )
