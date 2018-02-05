Spree.Views.Promotions.OptionValuesRule = Backbone.View.extend({
  optionValueSelectNameTemplate: HandlebarsTemplates['promotions/rules/option_values_select'],
  optionValueTemplate: HandlebarsTemplates['promotions/rules/option_values'],

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
    'click .js-add-promo-rule-option-value': 'onAdd',
    'click .js-remove-promo-rule-option-value': 'onRemove',
    'change .js-promo-rule-option-value-product-select': 'onSelectProduct'
  },

  addOptionValue: function(product, values) {
    var optionValue =
      this.$optionValues.append(
        this.optionValueTemplate({
          productSelect: { value: product },
          optionValuesSelect: { value: values },
          paramPrefix: this.paramPrefix
        })
      );

    optionValue.find('.js-promo-rule-option-value-product-select').productAutocomplete({multiple: false});
    optionValue.find('.js-promo-rule-option-value-option-values-select').optionValueAutocomplete({productSelect: '.js-promo-rule-option-value-product-select'})

    if(product == null) {
      optionValue.find('.js-promo-rule-option-value-option-values-select').prop('disabled', true);
    }
  },

  onAdd: function(e) {
    e.preventDefault();
    this.addOptionValue(null, null);
  },

  onRemove: function(e) {
    $(e.target).parent('.promo-rule-option-value').remove();
  },

  onSelectProduct: function(e) {
    var optionValueSelect = $(e.target).parents('.promo-rule-option-value').find('input.js-promo-rule-option-value-option-values-select')
    var optionValueSelectName = this.optionValueSelectNameTemplate({
      product_id: $(e.target).val(),
      param_prefix: this.paramPrefix
    }).trim();

    optionValueSelect.attr('name', optionValueSelectName);
    optionValueSelect.prop('disabled', $(e.target).val() == '').select2('val', '');
  },
});
