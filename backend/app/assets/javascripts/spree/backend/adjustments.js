Spree.ready(function() {
  $('[data-hook=adjustments_new_coupon_code] #add_coupon_code').click(function() {
    if ($("#coupon_code").val().length === 0) {
      return;
    }

    Spree.ajax({
      type: 'POST',
      url: Spree.pathFor('api/orders/' + window.order_number + '/coupon_codes'),
      data: {
        coupon_code: $("#coupon_code").val(),
        token: Spree.api_key
      },
      success: function() {
        window.location.reload();
      },
      error: function(msg) {
        if (msg.responseJSON["error"]) {
          show_flash('error', msg.responseJSON["error"]);
        } else {
          show_flash('error', "There was a problem adding this coupon code.");
        }
      }
    });
  });
});
