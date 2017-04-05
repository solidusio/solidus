Spree.Views.NumberWithCurrency = Backbone.View.extend({
  events: {
    'change input,select': "render"
  },

  initialize: function() {
    this.$currencySelector = this.$('.number-with-currency-select select');
    this.$amount = this.$('.number-with-currency-amount');
    this.$symbol = this.$('.number-with-currency-symbol');
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
    this.$symbol.text(this.getCurrencySymbol());

    var currency = this.getCurrency();
    if (currency) {
      var currencyInfo = Spree.currencyInfo[currency];
      var format = function(number) {
        return accounting.formatNumber(number, {
          precision: currencyInfo[1],
          thousand: '',
          decimal: '.',
        })
      }
      this.$amount.val(format(this.$amount.val()));
      this.$amount.prop("placeholder", format('0.00'));
      this.$amount.prop("step", 1 / (10 ** currencyInfo[1]));
    }
  }
});
