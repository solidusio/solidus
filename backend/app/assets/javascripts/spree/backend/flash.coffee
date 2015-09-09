$ ->
  # Make flash messages dissapear
  setTimeout('$(".flash").fadeOut()', 5000)

window.show_flash = (type, message) ->
  flash_div = $(".flash.#{type}")
  if flash_div.length == 0
    flash_div = $("<div class=\"flash #{type}\" />")
    $('#wrapper').prepend(flash_div)
  flash_div.html(message).show().delay(5000).fadeOut(500)
