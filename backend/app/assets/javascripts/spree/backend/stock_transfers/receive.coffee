$(document).ready ->
  if $('#received-transfer-items').length > 0
    Spree.StockTransfers.VariantForm.initializeForm()
    Spree.StockTransfers.VariantForm.beginListeningForReceive()
    Spree.StockTransfers.CountUpdateForms.beginListening(true)

    $("#close-transfer-button").on('click', (ev) ->
      ev.preventDefault()
      $('#close-stock-transfer-warning').show()
    )

    $("#cancel-close-link").on('click', (ev) ->
      ev.preventDefault()
      $('#close-stock-transfer-warning').hide()
    )
