Spree.ready(function() {
  var order_id = $('#payments').data('order-id');

  $('tr.payment').each(function() {
    var payment_id = $(this).data('payment-id');
    var model = new Spree.Models.Payment({
      id: payment_id,
      order_id: order_id
    });

    new Spree.Views.Payment.PaymentRow({
      el: this,
      model: model
    });
  });
});
