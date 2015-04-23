$(document).ready ->
  if $('#received-transfer-items').length > 0
    Spree.StockTransfers.ReceiveVariantForm.initializeForm()
    Spree.StockTransfers.ReceiveVariantForm.beginListening()
    Spree.StockTransfers.ReceiveUpdateForms.beginListening()

    $("#finalize-transfer-button").on('click', (ev) ->
      ev.preventDefault()
      $('#finalize-warning').show()
    )

    $("#cancel-finalize-link").on('click', (ev) ->
      ev.preventDefault()
      $('#finalize-warning').hide()
    )
