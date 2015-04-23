class ReceiveVariantForm
  @initializeForm: ->
    autoCompleteEl().variantAutocomplete()
    resetVariantAutocomplete()

  @beginListening: ->
    variantSelector = autoCompleteEl()
    # Search result selected
    variantSelector.on 'select2-selecting', (ev) =>
      ev.preventDefault()
      receiveTransferItem(ev.val)
    # Search results came back from the server
    variantSelector.on 'select2-loaded', (ev) =>
      if ev.items.results.length == 1
        receiveTransferItem(ev.items.results[0].id)

  autoCompleteEl = ->
    @variantAutocomplete ?= $('[data-hook="transfer_item_selection"]').find('.variant_autocomplete')
    @variantAutocomplete

  resetVariantAutocomplete = ->
    autoCompleteEl().select2('val', '').trigger('change').select2('open')

  receiveTransferItem = (variantId) ->
    stockTransferNumber = $("#stock_transfer_number").val()
    $(".select2-results").html("<li class='select2-no-results'>#{Spree.translations.receiving_match}</li>")
    stockTransfer = new Spree.StockTransfer
      number: stockTransferNumber
    stockTransfer.receive(variantId, successHandler, errorHandler)

  successHandler = (stockTransfer, variantId) =>
    resetVariantAutocomplete()
    stockTransfer = new Spree.StockTransfer
      number: stockTransfer.number
      transferItems: stockTransfer.transfer_items
    transferItem = stockTransfer.findTransferItemByVariantId(variantId)
    rowTemplate = Handlebars.compile($('#receive-count-for-transfer-item-template').html())

    htmlOutput = rowTemplate(
      id: transferItem.id
      variantDisplayAttributes: formatVariantDisplayAttributes(transferItem.variant)
      variantOptions: formatVariantOptionValues(transferItem.variant)
      variantImageURL: transferItem.variant.images[0]?.small_url
      receivedQuantity: transferItem.received_quantity
    )
    $("tr[data-transfer-item-id='#{transferItem.id}']").remove()
    if $("#listing_received_transfer_items tbody tr:first").length > 0
      $("#listing_received_transfer_items tbody tr:first").before(htmlOutput)
    else
      $("#listing_received_transfer_items tbody").html(htmlOutput)
    $("#listing_received_transfer_items").prop('hidden', false)
    $("#received-transfer-items .no-objects-found").prop('hidden', true)
    $("tr[data-transfer-item-id='#{transferItem.id}']").fadeIn()
    Spree.StockTransfers.ReceivedCounter.updateTotal()
    show_flash('success', Spree.translations.received_successfully)

  errorHandler = (errorData) ->
    resetVariantAutocomplete()
    errorMessage = if errorData.responseJSON.errors?
      errorData.responseText
    else
      errorData.responseJSON.error
    show_flash('error', errorMessage)

  formatVariantDisplayAttributes = (variant) ->
    displayAttributes = JSON.parse($("#variant_display_attributes").val())
    _.map(displayAttributes, (attribute) =>
      label: Spree.translations[attribute.string_key]
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
Spree.StockTransfers.ReceiveVariantForm = ReceiveVariantForm
