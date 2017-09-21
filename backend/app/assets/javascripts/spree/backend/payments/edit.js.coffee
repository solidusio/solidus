Spree.ready ->
  order_id = $('#payments').data('order-id')
  Payment = Backbone.Model.extend
    urlRoot: Spree.routes.payments_api(order_id)

  $('tr.payment').each ->
    model = new Payment({id: $(@).data('payment-id')})
    new Spree.Views.Payment.PaymentRow({el: @, model: model})
