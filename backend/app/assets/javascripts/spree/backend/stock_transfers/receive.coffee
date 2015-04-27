$(document).ready ->
  if $('#received-transfer-items').length > 0
    Spree.StockTransfers.ReceiveVariantForm.initializeForm()
    Spree.StockTransfers.ReceiveVariantForm.beginListening()
    Spree.StockTransfers.ReceiveUpdateForms.beginListening()

    $("#close-transfer-button").on('click', (ev) ->
      ev.preventDefault()
      $('#close-stock-transfer-warning').show()
    )

    $("#cancel-close-link").on('click', (ev) ->
      ev.preventDefault()
      $('#close-stock-transfer-warning').hide()
    )
