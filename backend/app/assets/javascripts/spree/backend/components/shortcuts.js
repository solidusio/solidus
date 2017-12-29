$(function() {
  var quickSwitch = new Spree.Views.QuickSwitch({
    el: $("[data-js='quick-switch']")
  });

  var onKeypress = function(e) {
    if(
      e.target.tagName === "INPUT" ||
      e.target.tagName === "SELECT" ||
      e.target.tagName === "TEXTAREA"
    ) {
      return
    } else if(e.key === "@") {
      quickSwitch.triggerShortcut()
    }
  };

  $(document.body).on("keypress", onKeypress);
});
