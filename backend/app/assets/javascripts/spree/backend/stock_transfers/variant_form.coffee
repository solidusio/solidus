class VariantForm
  @initializeForm: ->
    autoCompleteEl().variantAutocomplete()
    resetVariantAutocomplete()

  @beginListeningForReceive: ->
    variantSelector = autoCompleteEl()
    # Search result selected
    variantSelector.on 'select2-selecting', (ev) =>
      ev.preventDefault()
      receiveTransferItem(ev.val)
    # Search results came back from the server
    variantSelector.on 'select2-loaded', (ev) =>
      if ev.items.results.length == 1
        receiveTransferItem(ev.items.results[0].id)

  @beginListeningForAdd: ->
    variantSelector = autoCompleteEl()
    # Search result selected
    variantSelector.on 'select2-selecting', (ev) =>
      ev.preventDefault()
      createTransferItem(ev.val)
    # Search results came back from the server
    variantSelector.on 'select2-loaded', (ev) =>
      if ev.items.results.length == 1
        createTransferItem(ev.items.results[0].id)

  autoCompleteEl = ->
    @variantAutocomplete ?= $('[data-hook="transfer_item_selection"]').find('.variant_autocomplete')
    @variantAutocomplete

  resetVariantAutocomplete = ->
    autoCompleteEl().select2('val', '').trigger('change').select2('open')

  createTransferItem = (variantId) ->
    stockTransferNumber = $("#stock_transfer_number").val()
    $(".select2-results").html("<li class='select2-no-results'>#{Spree.translations.adding_match}</li>")
    transferItemRow = $("[data-variant-id='#{variantId}']")
    if transferItemRow.length > 0
      transferItemId = transferItemRow.parents('tr:first').data('transfer-item-id')
      expectedQuantity = parseInt($("#number-update-#{transferItemId}").find('.js-number-update-text').text().trim(), 10)
      transferItem = new Spree.TransferItem
        id: transferItemId
        stockTransferNumber: stockTransferNumber
        expectedQuantity: expectedQuantity
      transferItem.update(updateSuccessHandler, errorHandler)
    else
      transferItem = new Spree.TransferItem
        stockTransferNumber: stockTransferNumber
        variantId: variantId
        expectedQuantity: 1
      transferItem.create(createSuccessHandler, errorHandler)

  receiveTransferItem = (variantId) ->
    stockTransferNumber = $("#stock_transfer_number").val()
    $(".select2-results").html("<li class='select2-no-results'>#{Spree.translations.receiving_match}</li>")
    stockTransfer = new Spree.StockTransfer
      number: stockTransferNumber
    stockTransfer.receive(variantId, receiveSuccessHandler, errorHandler)

  createSuccessHandler = (transferItem) =>
    successHandler(transferItem, false)
    show_flash('success', Spree.translations.created_successfully)

  updateSuccessHandler = (transferItem) =>
    successHandler(transferItem, false)
    show_flash('success', Spree.translations.updated_successfully)

  receiveSuccessHandler = (stockTransfer, variantId) =>
    stockTransfer = new Spree.StockTransfer
      number: stockTransfer.number
      transferItems: stockTransfer.transfer_items
    transferItem = stockTransfer.findTransferItemByVariantId(variantId)
    successHandler(transferItem, variantId, true)
    Spree.StockTransfers.ReceivedCounter.updateTotal()
    show_flash('success', Spree.translations.received_successfully)

  successHandler = (transferItem, isReceiving) =>
    resetVariantAutocomplete()
    rowTemplate = Handlebars.compile($('#transfer-item-template').html())
    templateAttributes =
      id: transferItem.id
      isReceiving: isReceiving
      variantId: transferItem.variant.id
      variantDisplayAttributes: formatVariantDisplayAttributes(transferItem.variant)
      variantOptions: formatVariantOptionValues(transferItem.variant)
      variantImageURL: transferItem.variant.images[0]?.small_url

    if isReceiving
      templateAttributes["receivedQuantity"] = transferItem.received_quantity
    else
      templateAttributes["expectedQuantity"] = transferItem.expected_quantity

    htmlOutput = rowTemplate(templateAttributes)
    $("tr[data-transfer-item-id='#{transferItem.id}']").remove()
    if $("#listing_transfer_items tbody tr:first").length > 0
      $("#listing_transfer_items tbody tr:first").before(htmlOutput)
    else
      $("#listing_transfer_items tbody").html(htmlOutput)
    $("#listing_transfer_items").prop('hidden', false)
    $(".no-objects-found").prop('hidden', true)
    $("tr[data-transfer-item-id='#{transferItem.id}']").fadeIn()

  errorHandler = (errorData) ->
    resetVariantAutocomplete()
    errorMessage = if errorData.responseJSON?.error? and !errorData.responseJSON.errors?
      errorData.responseJSON.error
    else
      errorData.responseText
    show_flash('error', errorMessage)

  formatVariantDisplayAttributes = (variant) ->
    displayAttributes = JSON.parse($("#variant_display_attributes").val())
    _.map(displayAttributes, (attribute) =>
      label: Spree.translations[attribute.translation_key]
      value: variant[attribute.attr_name]
    )

  formatVariantOptionValues = (variant) ->
    optionValues = variant.option_values
    optionValues = _.sortBy(optionValues, 'option_type_presentation')
    _.map(optionValues, (optionValue) ->
      option_type: optionValue.option_type_presentation
      option_value: optionValue.presentation
    )

Spree.StockTransfers ?= {}
Spree.StockTransfers.VariantForm = VariantForm
