$(document).ready ->
  $("#new-variant-image-rule-image-button").on("click", (ev) ->
    ev.preventDefault()
    $(ev.currentTarget).hide()
    $("#new-variant-image-rule-image-form").show()
  )
  $("#new-variant-image-rule-image-form .fa-remove").on("click", (ev) ->
    ev.preventDefault()
    $(ev.currentTarget).parents("form:first").hide()
    $("#new-variant-image-rule-image-button").show()
  )
