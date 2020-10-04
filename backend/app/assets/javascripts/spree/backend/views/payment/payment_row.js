Spree.Views.Payment.PaymentRow = Backbone.View.extend({
  events: {
    "click .js-edit": "onEdit",
    "click .js-save": "onSave",
    "submit form": "onSave",
    "click .js-cancel": "onCancel"
  },

  onEdit: function(e) {
    e.preventDefault();
    this.$el.addClass("editing");
  },

  onCancel: function(e) {
    e.preventDefault();
    this.$el.removeClass("editing");
  },

  onSave: function(e) {
    var view = this;
    var amount = this.$(".js-edit-amount").val();
    var options = {
      success: function(model, response, options) {
        view.$(".js-display-amount").text(model.attributes.display_amount);
        view.$el.removeClass("editing");
      },
      error: function(model, response, options) {
        show_flash('error', response.responseJSON.error);
      }
    };
    e.preventDefault();
    this.model.save({
      amount: amount
    }, options);
  }
});
