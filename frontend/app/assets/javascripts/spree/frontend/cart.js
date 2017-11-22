Spree.ready(function($) {
  if (($('form#update-cart')).is('*')) {
    ($('form#update-cart a.delete')).show().one('click', function() {
      ($(this)).parents('.line-item').first().find('input.line_item_quantity').val(0);
      ($(this)).parents('form').first().submit();
      return false;
    });
  }
  return ($('form#update-cart')).submit(function() {
    return ($('form#update-cart #update-button')).attr('disabled', true);
  });
});

Spree.fetch_cart = function(cartLinkUrl) {
  return Spree.ajax({
    url: cartLinkUrl || Spree.pathFor("cart_link"),
    success: function(data) {
      return $('#link-to-cart').html(data);
    }
  });
};
