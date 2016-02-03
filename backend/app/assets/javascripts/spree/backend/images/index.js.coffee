$ ->
  ($ '#new_image_link').click (event) ->
    event.preventDefault()

    ($ '.no-objects-found').hide()

    ($ this).hide()
    Spree.ajax
      type: 'GET'
      url: @href
      data: (
        token: Spree.api_key
      )
      success: (r) ->
        ($ '#images').html r
        ($ '.select2').select2()
