errorHandler = (model, response, options) ->
  show_flash("error", response.responseText)

Spree.EditStockItemView = Backbone.View.extend
  tagName: 'tr'

  initialize: (options) ->
    @stockLocationName = options.stockLocationName
    @editing = false
    @render()

  events:
    "click .edit": "onEdit"
    "click .submit": "onSubmit"
    "click .cancel": "onCancel"

  template: HandlebarsTemplates['stock_items/stock_location_stock_item']

  render: ->
    renderAttr =
      stockLocationName: @stockLocationName
      editing: @editing
    _.extend(renderAttr, @model.attributes)

    @$el.attr("data-variant-id", @model.get('variant_id'))
    @$el.html(@template(renderAttr))

    return @

  onEdit: (ev) ->
    ev.preventDefault()
    @editing = true
    @render()

  onCancel: (ev) ->
    ev.preventDefault()
    @model.set(@model.previousAttributes())
    @editing = false
    @render()

  onSuccess: ->
    @editing = false
    @render()
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
