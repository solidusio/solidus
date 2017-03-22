Spree.Views.NumberWithCurrency = Backbone.View.extend({
  events: {
    'change input,select': "render"
  },

  render: function() {
    var currency, symbol = '';
    if (this.$('.currency-selector option:selected').length) {
      currency = this.$('.currency-selector option:selected').val();
    } else {
      currency = this.$('[data-currency]').data("currency");
    }
    if (currency) {
      var currencyInfo = Spree.currencyInfo[currency];
      this.$('.currency-selector-symbol').text(currencyInfo[0])
    } else {
      this.$('.currency-selector-symbol').text("");
    }
  }
});
