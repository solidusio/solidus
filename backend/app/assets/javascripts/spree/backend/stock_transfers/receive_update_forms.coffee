class ReceiveUpdateForms
  @beginListening: ->
    # Edit
    $('body').on 'click', '#listing_received_transfer_items .fa-edit', (ev) =>
      ev.preventDefault()
      transferItemId = $(ev.currentTarget).data('id')
      hideReadOnlyElements(transferItemId)
      resetReceivedItemsInput(transferItemId)
      showEditForm(transferItemId)

    # Cancel
    $('body').on 'click', '#listing_received_transfer_items .fa-void', (ev) =>
      ev.preventDefault()
      transferItemId = $(ev.currentTarget).data('id')
      hideEditForm(transferItemId)
      showReadOnlyElements(transferItemId)

    # Submit
    $('body').on 'click', '#listing_received_transfer_items .fa-check', (ev) =>
      ev.preventDefault()
      transferItemId = $(ev.currentTarget).data('id')
      stockTransferNumber = $("#stock_transfer_number").val()
      receivedQuantity = parseInt($("#received-quantity-#{transferItemId} input[type='number']").val(), 10)

      transferItem = new Spree.TransferItem
        id: transferItemId
        stockTransferNumber: stockTransferNumber
        receivedQuantity: receivedQuantity
      transferItem.update(successHandler, errorHandler)

  showReadOnlyElements = (transferItemId) ->
    toggleReadOnlyElements(transferItemId, true)

  hideReadOnlyElements = (transferItemId) ->
    toggleReadOnlyElements(transferItemId, false)

  toggleReadOnlyElements = (transferItemId, show) ->
    textCssDisplay = if show then 'block' else 'none'
    toggleButtonVisibility('edit', transferItemId, show)
    $("#received-quantity-#{transferItemId} span").css('display', textCssDisplay)

  showEditForm = (transferItemId) ->
    toggleEditFormVisibility(transferItemId, true)

  hideEditForm = (transferItemId) ->
    toggleEditFormVisibility(transferItemId, false)

  toggleEditFormVisibility = (transferItemId, show) ->
    inputCssDisplay = if show then 'block' else 'none'
    toggleButtonVisibility('void', transferItemId, show)
    toggleButtonVisibility('check', transferItemId, show)
    $("#received-quantity-#{transferItemId} input[type='number']").css('display', inputCssDisplay)

  toggleButtonVisibility = (buttonIcon, transferItemId, show) ->
    cssDisplay = if show then 'inline-block' else 'none'
    $(".fa-#{buttonIcon}[data-id='#{transferItemId}']").css('display', cssDisplay)

  resetReceivedItemsInput = (transferItemId) ->
    tableCell = $("#received-quantity-#{transferItemId}")
    countText = tableCell.find('span').text().trim()
    tableCell.find("input[type='number']").val(countText)

  successHandler = (transferItem) =>
    $("#received-quantity-#{transferItem.id} span").text(transferItem.received_quantity)
    hideEditForm(transferItem.id)
    showReadOnlyElements(transferItem.id)
    Spree.StockTransfers.ReceivedCounter.updateTotal()
    show_flash("success", Spree.translations.updated_successfully)

  errorHandler = (errorData) =>
    show_flash("error", errorData.responseText)

Spree.StockTransfers ?= {}
Spree.StockTransfers.ReceiveUpdateForms = ReceiveUpdateForms
