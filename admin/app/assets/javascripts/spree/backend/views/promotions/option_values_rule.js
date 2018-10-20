Spree.Views.Promotions.OptionValuesRuleRow = Backbone.View.extend({
  optionValueTemplate: HandlebarsTemplates['promotions/rules/option_values'],

  events: {
    'click .js-remove-promo-rule-option-value': 'onRemove',
    'change .js-promo-rule-option-value-product-select': 'onSelectProduct'
  },

  initialize: function(options) {
    this.productId = options.productId;
    this.values = options.values;
    this.paramPrefix = options.paramPrefix;
  },

  render: function() {
    this.$el.html(
      this.optionValueTemplate({
        productSelect: { value: this.productId },
        optionValuesSelect: { value: this.values },
        paramPrefix: this.paramPrefix
      })
    );

    this.$('.js-promo-rule-option-value-product-select').productAutocomplete({multiple: false});

    // Note: This doesn't work. This always selects the first product select on the page.
    // optionValueAutocomplete also doesn't work, so this cancels out.
    this.$('.js-promo-rule-option-value-option-values-select').optionValueAutocomplete({productSelect: '.js-promo-rule-option-value-product-select'})

    if(this.productId == null) {
      this.$('.js-promo-rule-option-value-option-values-select').prop('disabled', true);
    }
  },

  onSelectProduct: function(e) {
    this.productId = this.$('input.js-promo-rule-option-value-product-select').val();
    this.render();
  },

  onRemove: function(e) {
    this.remove();
  },
});

Spree.Views.Promotions.OptionValuesRule = Backbone.View.extend({
  initialize: function() {
    _.bindAll(this, 'addOptionValue')
    this.$optionValues = this.$('.js-promo-rule-option-values');
    this.paramPrefix = this.$('.param-prefix').data('param-prefix');

    var originalOptionValues = this.$optionValues.data('original-option-values')
    if ($.isEmptyObject(originalOptionValues)) {
      this.addOptionValue(null, null);
    } else {
      $.each(originalOptionValues, this.addOptionValue);
    }
  },

  events: {
    'click .js-add-promo-rule-option-value': 'onAdd'
  },

  addOptionValue: function(product, values) {
    var row = new Spree.Views.Promotions.OptionValuesRuleRow({
      productId: product,
      values: values,
      paramPrefix: this.paramPrefix
    });

    this.$optionValues.append(row.el);

    row.render();
  },

  onAdd: function(e) {
    e.preventDefault();
    this.addOptionValue(null, null);
  },
});
