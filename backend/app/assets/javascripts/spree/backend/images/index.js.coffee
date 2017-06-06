$ ->
  ($ '#new_image_link').click (event) ->
    event.preventDefault()

    ($ '.no-objects-found').hide()

    ($ this).hide()
    Spree.ajax
      type: 'GET'
      url: @href
      success: (r) ->
        ($ '#images').html r
        ($ 'select.select2').select2()
