Spree.Views.Payment.New = Backbone.View.extend({
  initialize: function() {
    this.onSelectMethod()
  },

  events: {
    'change [name="payment[payment_method_id]"]': 'onSelectMethod',
    'change .cardNumber': 'onChangeCard'
  },

  onSelectMethod: function(e) {
    this.selectedId = parseInt(this.$('input[name="payment[payment_method_id]"]:checked').val())
    this.render();
  },

  render: function() {
    var view = this;
    this.$('.payment-method-settings .payment-methods').each(function() {
      var $method = $(this);
      var selected = $method.data("payment-method-id") === view.selectedId;
      $method.toggleClass('hidden', !selected);
      $method.find(':input').prop('disabled', !selected);
    });
  }
});
