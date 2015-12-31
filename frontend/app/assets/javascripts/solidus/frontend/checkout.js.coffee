//= require jquery.payment
//= require_self
//= require solidus/frontend/checkout/address
//= require solidus/frontend/checkout/payment

Solidus.disableSaveOnClick = ->
  ($ 'form.edit_order').submit ->
    ($ this).find(':submit, :image').attr('disabled', true).removeClass('primary').addClass 'disabled'

Solidus.ready ($) ->
  Solidus.Checkout = {}
