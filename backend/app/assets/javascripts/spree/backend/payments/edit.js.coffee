Spree.ready ->
  order_id = $('#payments').data('order-id')

  $('tr.payment').each ->
    payment_id = $(@).data('payment-id')
    model = new Spree.Models.Payment({id: payment_id, order_id: order_id})
    new Spree.Views.Payment.PaymentRow({el: @, model: model})
