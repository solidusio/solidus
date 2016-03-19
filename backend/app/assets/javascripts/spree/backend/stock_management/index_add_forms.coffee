Spree.AddStockItemView = Backbone.View.extend
  initialize: ->
    @$countInput = @$("[name='count_on_hand']")
    @$locationSelect = @$("[name='stock_location_id']")
    @$backorderable = @$("[name='backorderable']")

  events:
    "click .submit": "onSubmit"

  validate: ->
    locationSelectContainer = @$locationSelect.siblings('.select2-container')
    locationSelectContainer.toggleClass('error', !@$locationSelect.val())
    @$countInput.toggleClass('error', !@$countInput.val())

    locationSelectContainer.hasClass('error') || @$countInput.hasClass('error')

  onSuccess: ->
    selectedStockLocationOption = @$locationSelect.find('option:selected')
    stockLocationName = selectedStockLocationOption.text().trim()
    selectedStockLocationOption.remove()

    editView = new Spree.EditStockItemView
      model: @model
      stockLocationName: stockLocationName
    editView.$el.insertBefore(@$el)

    @model = new Spree.StockItem
      variant_id: @model.get('variant_id')
      stock_location_id: @model.get('stock_location_id')

    if @$locationSelect.find('option').length is 1 # blank value
      @remove()
    else
      @$locationSelect.select2()
      @$countInput.val("")
      @$backorderable.prop("checked", false)

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
