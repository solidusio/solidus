Spree.Views.NumberWithCurrency = Backbone.View.extend({
  events: {
    'change input,select': "render"
  },

  getCurrency: function() {
    if (this.$('.currency-selector option:selected').length) {
      return this.$('.currency-selector option:selected').val();
    } else {
      return this.$('[data-currency]').data("currency");
    }
  },

  getCurrencySymbol: function() {
    var currency = this.getCurrency();
    if (currency) {
      var currencyInfo = Spree.currencyInfo[currency];
      return currencyInfo[0];
    } else {
      return '';
    }
  },

  render: function() {
    this.$('.currency-selector-symbol').text(this.getCurrencySymbol());
  }
});
