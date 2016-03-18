errorHandler = (model, response, options) ->
  show_flash("error", response.responseText)

Spree.EditStockItemView = Backbone.View.extend
  tagName: 'tr'

  initialize: (options) ->
    @stockLocationName = options.stockLocationName
    @render()

  events:
    "click .fa-edit":  "onEdit"
    "click .fa-check": "onSubmit"
    "click .fa-void":  "onCancel"

  template: HandlebarsTemplates['stock_items/stock_location_stock_item']

  render: ->
    renderAttr =
      StockLocationName: @stockLocationName
    _.extend(renderAttr, @model.attributes)

    @$el.attr("data-variant-id", @model.get('variant_id'))
    @$el.html(@template(renderAttr))

    return @

  onEdit: (ev) ->
    ev.preventDefault()
    @$('[name=backorderable]').prop('disabled', false)
    stockItemId = @model.id
    Spree.NumberFieldUpdater.hideReadOnly(stockItemId)
    Spree.NumberFieldUpdater.showForm(stockItemId)

  onCancel: (ev) ->
    ev.preventDefault()
    backorderableWas = @model.previous('backorderable')
    @$('[name=backorderable]').prop('disabled', true).val(backorderableWas)
    stockItemId = @model.id
    Spree.NumberFieldUpdater.hideForm(stockItemId)
    Spree.NumberFieldUpdater.showReadOnly(stockItemId)

  onSuccess: ->
    @$('[name=backorderable]').prop('disabled', true)
    Spree.NumberFieldUpdater.successHandler(@model.id, @model.get('count_on_hand'))
    show_flash("success", Spree.translations.updated_successfully)

  onSubmit: (ev) ->
    ev.preventDefault()
    backorderable = @$('[name=backorderable]').prop("checked")
    countOnHand = parseInt($("input[name='count_on_hand']").val(), 10)

    @model.set
      count_on_hand: countOnHand
      backorderable: backorderable
    options =
      success: => @onSuccess()
      error: errorHandler
    @model.save(force: true, options)

$ ->
  $('.js-edit-stock-item').each ->
    $el = $(this)
    model = new Spree.StockItem($el.data('stock-item'))
    new Spree.EditStockItemView
      el: $el
      stockLocationName: $el.data('stock-location-name')
      model: model
