Spree.Views.QuickSwitch = Backbone.View.extend({
  events: {
    "shown.bs.modal": "onShow",
    "hidden.bs.modal": "onHide",
    "submit form": "onSubmit"
  },

  initialize: function() {
    this.$el = $(this.el);
    this.$dialog = $("[data-js='quick-switch-dialog']", this.$el);
    this.$form = $("form", this.$el);
    this.$input = $("[data-js='quick-switch-input']", this.$el);
    this.$tooltip = $("[data-js='quick-switch-tooltip']", this.$el);
		this.render();
  },

  triggerShortcut: function() {
    this.onShortcut();
  },

  onShortcut: function() {
    this.$el.modal("toggle");
  },

  onShow: function() {
    this.$input.focus();
  },

  onHide: function() {
    this.$input.val("");
    $(".alert", this.$dialog).remove();
  },

  onSubmit: function(e) {
    e.preventDefault();
    this.toggleSearchClass();
    this.sendQuery();
  },

  toggleSearchClass: function() {
    this.$form.toggleClass("searching");
  },

  sendQuery: function() {
    var view = this;
    Spree.ajax({
      dataType: "json",
      url: this.$form.attr("action"),
      type: "GET",
      data: this.$form.serializeArray(),
      global: false, // disable the backend's default loading messaging
      success: function(response) {
        if(response.redirect_url) {
          window.location = response.redirect_url;
        }
      },
      error: function(response) {
        var message = JSON.parse(response.responseText).message;
        view.toggleSearchClass();
        if($(".alert", view.$el).length) {
          $(".alert", view.$el).text(message);
        } else {
          view.$dialog.append("<div class='alert alert-warning'>" + message + "</div>");
        }
      }
    });
  },

  render: function() {
  }
});
