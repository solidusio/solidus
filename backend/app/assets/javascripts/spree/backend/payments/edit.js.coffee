PaymentRowView = Backbone.View.extend
  events:
    "click .js-edit": "onEdit"
    "click .js-save": "onSave"
    "click .js-cancel": "onCancel"
    "click .js-display-amount": "onEdit"

  onEdit: (e) ->
    e.preventDefault()
    @$el.addClass("editing")

  onCancel: (e) ->
    e.preventDefault()
    @$el.removeClass("editing")

  onSave: (e) ->
    e.preventDefault()
    amount = @$(".js-edit-amount").val()
    options =
      success: (model, response, options) =>
        @$(".js-display-amount").text(model.attributes.display_amount)
        @$el.removeClass("editing")
      error: (model, response, options) =>
        show_flash 'error', response.responseJSON.error
    @model.save({ amount: amount }, options)

$ ->
  order_id = $('#payments').data('order-id')
  Payment = Backbone.Model.extend
    urlRoot: Spree.routes.payments_api(order_id)

  $('tr.payment').each ->
    model = new Payment({id: $(@).data('payment-id')})
    new PaymentRowView({el: @, model: model})
