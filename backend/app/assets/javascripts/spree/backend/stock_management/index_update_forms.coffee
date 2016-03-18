errorHandler = (model, response, options) ->
  show_flash("error", response.responseText)

EditStockItemView = Backbone.View.extend
  events:
    "click .fa-edit":  "onEdit"
    "click .fa-check": "onSubmit"
    "click .fa-void":  "onCancel"

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
    new EditStockItemView
      el: $el
      model: model
