support.withTranslations = function(translations) {
  beforeEach(function() {
    this._oldTranslations = Spree.translations;
    Spree.translations = translations;
  });

  afterEach(function() {
    Spree.translations = this._oldTranslations;
  });
};

