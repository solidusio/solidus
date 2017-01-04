#= require jquery.payment
#= require_self
#= require spree/frontend/checkout/address
#= require spree/frontend/checkout/payment
#= require spree/frontend/checkout/coupon-code

Spree.disableSaveOnClick = ->
  ($ 'form.edit_order').submit ->
    ($ this).find(':submit, :image').attr('disabled', true).removeClass('primary').addClass 'disabled'

Spree.ready ($) ->
  termsCheckbox = ($ '#accept_terms_and_conditions')
  termsCheckbox.change( () ->
    submitBtn = $(this.closest('form')).find(':submit')
    submitBtn.prop('disabled', !this.checked)
    submitBtn.toggleClass('disabled', !this.checked)
  )
