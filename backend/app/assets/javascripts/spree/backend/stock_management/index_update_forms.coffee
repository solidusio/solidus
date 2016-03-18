storeBackorderableState = (stockItemId) ->
  backorderableCheckbox = $("#backorderable-#{stockItemId}")
  backorderableCheckbox.parent('td').attr('was-checked', backorderableCheckbox.prop('checked'))

restoreBackorderableState = (stockItemId) ->
  backorderableCheckbox = $("#backorderable-#{stockItemId}")
  checked = backorderableCheckbox.parent('td').attr('was-checked') is "true"
  backorderableCheckbox.prop('checked', checked)

successHandler = (model, response, options) =>
  toggleBackorderable(model.get('id'), false)
  Spree.NumberFieldUpdater.successHandler(model.get('id'), model.get('count_on_hand'))
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
    stockItemId = $(ev.currentTarget).data('id')
    storeBackorderableState(stockItemId)
    Spree.NumberFieldUpdater.hideReadOnly(stockItemId)
    Spree.NumberFieldUpdater.showForm(stockItemId)

  onCancel: (ev) ->
    ev.preventDefault()
    @$('[name=backorderable]').prop('disabled', true)
    stockItemId = $(ev.currentTarget).data('id')
    restoreBackorderableState(stockItemId)
    Spree.NumberFieldUpdater.hideForm(stockItemId)
    Spree.NumberFieldUpdater.showReadOnly(stockItemId)

  onSubmit: (ev) ->
    ev.preventDefault()
    stockItemId = $(ev.currentTarget).data('id')
    stockLocationId = $(ev.currentTarget).data('location-id')
    backorderable = $("#backorderable-#{stockItemId}").prop("checked")
    countOnHand = parseInt($("#number-update-#{stockItemId} input[type='number']").val(), 10)

    stockItem = new Spree.StockItem
      id: stockItemId
      count_on_hand: countOnHand
      backorderable: backorderable
      stock_location_id: stockLocationId
    options =
      success: successHandler
      error: errorHandler
    stockItem.save(force: true, options)

$ ->
  $('.js-edit-stock-item').each ->
    new EditStockItemView
      el: this
