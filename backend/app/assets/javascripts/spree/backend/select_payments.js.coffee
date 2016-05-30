$ ->
  if $('.new_payment').is('*')
    $input = $('input[name="payment[payment_method_id]"]')
    $paymentMethods = $('.payment-method-settings .payment-methods')

    updateSelected = ->
      id = $input.filter(":checked").val()
      $paymentMethods.addClass('hidden')
      $paymentMethods.filter("#payment_method_#{id}").removeClass('hidden')

    $input.on('click', updateSelected)
    updateSelected()
