$(document).ready ->
  $('#confirm-ship-transfer-button').on('click', (ev) ->
    ev.preventDefault()
    $('#ship-stock-transfer-warning').show()
  )

  $('#cancel-ship-link').on('click', (ev) ->
    ev.preventDefault()
    $('#ship-stock-transfer-warning').hide()
  )
