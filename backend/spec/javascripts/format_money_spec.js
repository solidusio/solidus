describe('Spree.formatMoney', function() {
  it('can format USD', function() {
    expect(Spree.formatMoney(10, 'USD')).to.equal('$10.00');
    expect(Spree.formatMoney('10', 'USD')).to.equal('$10.00');
    expect(Spree.formatMoney(12.34, 'USD')).to.equal('$12.34');
    expect(Spree.formatMoney('12.34', 'USD')).to.equal('$12.34');
    expect(Spree.formatMoney(1000, 'USD')).to.equal('$1,000.00');
  });

  it('can format CAD', function() {
    expect(Spree.formatMoney(1000, 'CAD')).to.equal('$1,000.00');
  });

  it('can format GBP', function() {
    expect(Spree.formatMoney(1000, 'GBP')).to.equal('£1,000.00');
  });

  it('can format EUR', function() {
    expect(Spree.formatMoney(1000, 'EUR')).to.equal('€1,000.00');
  });

  it('can format YEN', function() {
    expect(Spree.formatMoney(1000, 'JPY')).to.equal('¥1,000');
  });

  describe('with comma as decimal', function() {
    support.withTranslations({
      currency_delimiter: ".",
      currency_separator: ","
    });

    it('can format USD', function() {
      expect(Spree.formatMoney(10, 'USD')).to.equal('$10,00');
      expect(Spree.formatMoney('10', 'USD')).to.equal('$10,00');
      expect(Spree.formatMoney(12.34, 'USD')).to.equal('$12,34');
      expect(Spree.formatMoney('12.34', 'USD')).to.equal('$12,34');
      expect(Spree.formatMoney(1000, 'GBP')).to.equal('£1.000,00');
    });

    it('can format EUR', function() {
      expect(Spree.formatMoney(1000, 'EUR')).to.equal('€1.000,00');
    });

    it('can format YEN', function() {
      expect(Spree.formatMoney(1000, 'JPY')).to.equal('¥1.000');
    });
  });
});
