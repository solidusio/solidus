describe('Spree.t', function() {
  support.withTranslations({
    simple: "simple",
    nested: {
      key: "nested key"
    },
    deeply: {
      nested: {
        key: "deeply nested key"
      }
    }
  })

  it('can get a simple key', function() {
    expect(Spree.t('simple')).to.equal('simple');
  });

  it('can get a nested key', function() {
    expect(Spree.t('nested.key')).to.equal('nested key');
  });

  it('can get a nested key using scope', function() {
    expect(Spree.t('key', {scope: 'nested'})).to.equal('nested key');
  });

  it('can get a deeply nested key', function() {
    expect(Spree.t('deeply.nested.key')).to.equal('deeply nested key');
  });

  it('can get a deeply nested key using scope', function() {
    expect(Spree.t('nested.key', {scope: 'deeply'})).to.equal('deeply nested key');
    expect(Spree.t('key', {scope: 'deeply.nested'})).to.equal('deeply nested key');
  });

  it('ignores default when key exists', function() {
    expect(Spree.t('simple', {default: 'foo'})).to.equal('simple');
  });

  it('returns a default for a missing key', function() {
    expect(Spree.t('does_not_exist', {default: 'foo'})).to.equal('foo');
  });
});

describe('Spree.human_attribute_name', function() {
  support.withTranslations({
    activerecord: {
      attributes: {
        "spree/model": {
          "name": "Name"
        }
      }
    }
  });

  it('can get attribute names', function() {
    expect(Spree.human_attribute_name('spree/model', "name")).to.equal('Name');
  });
});
