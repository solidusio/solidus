Spree.Views.NumberWithCurrency = Backbone.View.extend({
  events: {
    'change input,select': "render"
  },

  initialize: function() {
    this.$currencySelector = this.$('.number-with-currency-select');
  },

  getCurrency: function() {
    if (this.$currencySelector.length) {
      return this.$currencySelector.find('option:selected').val();
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
    this.$('.number-with-currency-symbol').text(this.getCurrencySymbol());
  }
});
