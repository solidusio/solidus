validate = (locationSelect, locationSelectContainer, countInput) ->
  locationSelectContainer.toggleClass('error', !locationSelect.val())
  countInput.toggleClass('error', !countInput.val())

hasErrors = (locationSelectContainer, countInput) ->
  locationSelectContainer.hasClass('error') or countInput.hasClass('error')

successHandler = (model, response, options) =>
  variantId = model.get('variant_id')
  stockLocationId = model.get('stock_location_id')
  stockLocationSelect = $("#variant-stock-location-#{variantId}")

  selectedStockLocationOption = stockLocationSelect.find("option[value='#{stockLocationId}']")
  stockLocationName = selectedStockLocationOption.text().trim()
  selectedStockLocationOption.remove()

  rowTemplate = HandlebarsTemplates['stock_items/stock_location_stock_item']
  $("tr[data-variant-id='#{variantId}']:last").before(
    rowTemplate
      id: model.get('id')
      variantId: variantId
      stockLocationId: stockLocationId
      stockLocationName: stockLocationName
      countOnHand: model.get('count_on_hand')
      backorderable: model.get('backorderable')
  )
  resetTableRowStyling(variantId)

  if stockLocationSelect.find('option').length is 1 # blank value
    stockLocationSelect.parents('tr:first').remove()
  else
    stockLocationSelect.select2()
    $("#variant-count-on-hand-#{variantId}").val("")
    $("#variant-backorderable-#{variantId}").prop("checked", false)

  resetParentRowspan(variantId)
  show_flash("success", Spree.translations.created_successfully)

errorHandler = (model, response, options) =>
  show_flash("error", response.responseText)

resetTableRowStyling = (variantId) ->
  tableRows = $("tr[data-variant-id='#{variantId}']")
  tableRows.removeClass('even odd')
  for i in [0..tableRows.length]
    rowClass = if (i + 1) % 2 is 0 then 'even' else 'odd'
    tableRows.eq(i).addClass(rowClass)

resetParentRowspan = (variantId) ->
  newRowspan = $("tr[data-variant-id='#{variantId}']").length + 1
  $("#spree_variant_#{variantId} > td").attr('rowspan', newRowspan)

AddStockItemView = Backbone.View.extend
  initialize: ->
    @$countInput = @$("[name='count_on_hand']")
    @$locationSelect = @$("[name='stock_location_id']")
    @$backorderable = @$("[name='backorderable']")

  events:
    "click .fa-plus": "onSubmit"

  onSubmit: (ev) ->
    ev.preventDefault()
    locationSelectContainer = @$locationSelect.siblings('.select2-container')
    validate(@$locationSelect, locationSelectContainer, @$countInput)
    return if hasErrors(locationSelectContainer, @$countInput)

    @model.set
      backorderable: @$backorderable.prop("checked")
      count_on_hand: @$countInput.val()
      stock_location_id: @$locationSelect.val()
    options =
      success: successHandler
      error: errorHandler
    @model.save(null, options)

$ ->
  $('.js-add-stock-item').each ->
    $el = $(this)
    model = new Spree.StockItem
      variant_id: $el.data('variant-id')
    new AddStockItemView
      el: $el
      model: model
