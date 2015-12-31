//= require jquery.payment
//= require_self
//= require solidus/frontend/checkout/address
//= require solidus/frontend/checkout/payment

Spree.disableSaveOnClick = ->
  ($ 'form.edit_order').submit ->
    ($ this).find(':submit, :image').attr('disabled', true).removeClass('primary').addClass 'disabled'

Spree.ready ($) ->
  Spree.Checkout = {}
