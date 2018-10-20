Spree.initNumberWithCurrency = function() {
  $('.js-number-with-currency').each(function() {
    var view = new Spree.Views.NumberWithCurrency({
      el: this,
    });
    view.render();
  });
}

Spree.ready(function() {
  Spree.initNumberWithCurrency()
})
