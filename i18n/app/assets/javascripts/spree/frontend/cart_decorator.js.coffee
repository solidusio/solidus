Spree.fetch_cart = (cartLinkUrl) ->
  Spree.ajax
    url: cartLinkUrl || Spree.pathFor("cart_link"),
    success: (data) ->
      $('#link-to-cart').html data