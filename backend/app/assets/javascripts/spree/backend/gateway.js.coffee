$ ->
  $gateway_type = $('select.js-gateway-type')
  $preference_source = $('select.js-preference-source')

  original_gtwy_type = $gateway_type.val()
  original_preference_source = $preference_source.val()
  render = ->
    gateway_type = $gateway_type.val()
    preference_source = $preference_source.val()

    $('.js-preference-source-wrapper').toggle(gateway_type == original_gtwy_type)
    if gateway_type == original_gtwy_type && preference_source == original_preference_source
      $('.js-gateway-settings').show()
      $('.js-gateway-settings-warning').hide()
    else
      $('.js-gateway-settings').hide()
      $('.js-gateway-settings-warning').show()

  $gateway_type.change(render)
  $preference_source.change(render)
  render()
