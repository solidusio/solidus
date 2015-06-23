$ ->
  $new_state = $("#new_state")
  if $new_state.length
    $new_state_link = $("#new_state_link")
    $country_select = $("#country")
    $cancel_button = $new_state.find(".fa-remove")
    $form = $new_state.find("form")
    $new_state.hide()

    $new_state_link.click (e) ->
      e.preventDefault()
      $new_state.show()
      $new_state_link.hide()

    $cancel_button.click (e) ->
      e.preventDefault()
      $new_state.hide()
      $new_state_link.show()

    $country_select.on 'change', (e) ->
      $form.attr 'action', $form.attr('action').replace(/countries\/(\d+)/, "countries/#{$country_select.val()}")

