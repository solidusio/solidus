(function() {
  var showTime = 5000;

  var fadeOutTime = 500;

  Spree.ready(function() {
    var $initialFlash;
    $initialFlash = $(".flash");
    setTimeout((function() {
      $initialFlash.fadeOut(fadeOutTime);
    }), showTime);
  });

  window.show_flash = function(type, message) {
    var $flashWrapper = $(".js-flash-wrapper");
    var flash_div = $("<div class=\"flash " + type + "\" />");
    $flashWrapper.prepend(flash_div);
    flash_div.html(message).show().delay(showTime).fadeOut(fadeOutTime);
  };
})();
