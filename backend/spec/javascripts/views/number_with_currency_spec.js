fixture.preload("number_with_currency/with_currency_select", "number_with_currency/without_select");

describe("Spree.Views.NumberWithCurrency", function() {
  var view, $el;
  var $symbol, $input, $select, $addon;

  var loadFixture = function(path) {
    var fixtures = fixture.load(path, true);
    $el = $(fixtures[0]);
  }

  var loadView = function() {
    view = new Spree.Views.NumberWithCurrency({el: $el});
    view.render();
    $symbol = $el.find('.number-with-currency-symbol');
    $input = $el.find('input');
    $select = $el.find('select');
    $addon = $el.find('.number-with-currency-addon');
  }

  describe("with currency selector", function() {
    beforeEach(function() {
      loadFixture("number_with_currency/with_currency_select");
      loadView();
    });

    it("has a default currency selected", function() {
      expect($select).to.have.$val('USD');
      expect($symbol).to.have.$text('$');
    });

    it("can select CAD", function() {
      $select.val('CAD').trigger('change');

      expect($select).to.have.$val('CAD');
      expect($symbol).to.have.$text('$');
    });

    it("can select GBP", function() {
      $select.val('GBP').trigger('change');

      expect($select).to.have.$val('GBP');
      expect($symbol).to.have.$text('£');
    });

    it("can select JPY", function() {
      $select.val('JPY').trigger('change');

      expect($select).to.have.$val('JPY');
      expect($symbol).to.have.$text('¥');
    });
  });

  describe("without currency selector", function() {
    beforeEach(function() {
      loadFixture("number_with_currency/without_select");
      loadView();
    });

    it("uses USD format", function() {
      $el.find('[data-currency]').data('currency', 'USD');
      view.render();
      expect($symbol).to.have.$text('$');
    });

    it("uses JPY format", function() {
      $el.find('[data-currency]').data('currency', 'JPY');
      view.render();
      expect($symbol).to.have.$text('¥');
    });
  });
});
