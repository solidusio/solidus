updateParentTable = (variantId) ->
  tableRows = $("tr[data-variant-id='#{variantId}']")
  tableRows.removeClass('even odd')
  for i in [0..tableRows.length]
    rowClass = if (i + 1) % 2 is 0 then 'even' else 'odd'
    tableRows.eq(i).addClass(rowClass)

  $("#spree_variant_#{variantId} > td").attr('rowspan', tableRows.length + 1)

Spree.AddStockItemView = Backbone.View.extend
  initialize: ->
    @$countInput = @$("[name='count_on_hand']")
    @$locationSelect = @$("[name='stock_location_id']")
    @$backorderable = @$("[name='backorderable']")

  events:
    "click .fa-plus": "onSubmit"

  validate: ->
    locationSelectContainer = @$locationSelect.siblings('.select2-container')
    locationSelectContainer.toggleClass('error', !@$locationSelect.val())
    @$countInput.toggleClass('error', !@$countInput.val())

    locationSelectContainer.hasClass('error') || @$countInput.hasClass('error')

  onSuccess: ->
    selectedStockLocationOption = @$locationSelect.find('option:selected')
    stockLocationName = selectedStockLocationOption.text().trim()
    selectedStockLocationOption.remove()

    rowTemplate = HandlebarsTemplates['stock_items/stock_location_stock_item']
    newRow = $(
      rowTemplate
        id: @model.get('id')
        variantId: @model.get('variant_id')
        stockLocationId: @model.get('stock_location_id')
        stockLocationName: stockLocationName
        countOnHand: @model.get('count_on_hand')
        backorderable: @model.get('backorderable')
    ).insertBefore(@$el)

    new Spree.EditStockItemView
      el: newRow
      model: @model

    @model = new Spree.StockItem
      variant_id: @model.get('variant_id')
      stock_location_id: @model.get('stock_location_id')

    if @$locationSelect.find('option').length is 1 # blank value
      @remove()
    else
      @$locationSelect.select2()
      @$countInput.val("")
      @$backorderable.prop("checked", false)

    updateParentTable(@model.get('variant_id'))

  onSubmit: (ev) ->
    ev.preventDefault()
    return if @validate()

    @model.set
      backorderable: @$backorderable.prop("checked")
      count_on_hand: @$countInput.val()
      stock_location_id: @$locationSelect.val()
    options =
      success: =>
        @onSuccess()
        show_flash("success", Spree.translations.created_successfully)
      error: (model, response, options) =>
        show_flash("error", response.responseText)
    @model.save(null, options)

$ ->
  $('.js-add-stock-item').each ->
    $el = $(this)
    model = new Spree.StockItem
      variant_id: $el.data('variant-id')
    new Spree.AddStockItemView
      el: $el
      model: model
