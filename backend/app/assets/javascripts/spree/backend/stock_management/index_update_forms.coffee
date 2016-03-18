storeBackorderableState = (stockItemId) ->
  backorderableCheckbox = $("#backorderable-#{stockItemId}")
  backorderableCheckbox.parent('td').attr('was-checked', backorderableCheckbox.prop('checked'))

restoreBackorderableState = (stockItemId) ->
  backorderableCheckbox = $("#backorderable-#{stockItemId}")
  checked = backorderableCheckbox.parent('td').attr('was-checked') is "true"
  backorderableCheckbox.prop('checked', checked)

successHandler = (model, response, options) =>
  toggleBackorderable(model.get('id'), false)
  Spree.NumberFieldUpdater.successHandler(model.id, model.get('count_on_hand'))
  show_flash("success", Spree.translations.updated_successfully)

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
    storeBackorderableState(stockItemId)
    Spree.NumberFieldUpdater.hideReadOnly(stockItemId)
    Spree.NumberFieldUpdater.showForm(stockItemId)

  onCancel: (ev) ->
    ev.preventDefault()
    @$('[name=backorderable]').prop('disabled', true)
    stockItemId = @model.id
    restoreBackorderableState(stockItemId)
    Spree.NumberFieldUpdater.hideForm(stockItemId)
    Spree.NumberFieldUpdater.showReadOnly(stockItemId)

  onSubmit: (ev) ->
    ev.preventDefault()
    stockItemId = @model.id
    stockLocationId = $(ev.currentTarget).data('location-id')
    backorderable = $("#backorderable-#{stockItemId}").prop("checked")
    countOnHand = parseInt($("#number-update-#{stockItemId} input[type='number']").val(), 10)

    @model.set
      count_on_hand: countOnHand
      backorderable: backorderable
    options =
      success: successHandler
      error: errorHandler
    @model.save(force: true, options)

$ ->
  $('.js-edit-stock-item').each ->
    $el = $(this)
    model = new Spree.StockItem($el.data('stock-item'))
    new EditStockItemView
      el: $el
      model: model
