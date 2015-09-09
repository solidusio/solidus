showTime = 5000
fadeOutTime = 500

$ ->
  # Make flash messages dissapear
  setTimeout('$(".flash").fadeOut()', 5000)

window.show_flash = (type, message) ->
  $flashWrapper = $(".js-flash-wrapper")
  flash_div = $("<div class=\"flash #{type}\" />")
  $flashWrapper.prepend(flash_div)
  flash_div.html(message).show().delay(showTime).fadeOut(fadeOutTime)
