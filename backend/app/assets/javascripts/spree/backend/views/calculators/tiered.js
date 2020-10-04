Spree.Views.Calculators.Tiered = Backbone.View.extend({
  initialize: function() {
    this.calculatorName = this.$('.js-tiers').data('calculator');
    this.tierFieldsTemplate = HandlebarsTemplates["promotions/calculators/fields/" + this.calculatorName];
    this.originalTiers = this.$('.js-tiers').data('original-tiers');
    this.formPrefix = this.$('.js-tiers').data('form-prefix');

    for (var base in this.originalTiers) {
      var value = this.originalTiers[base];
      this.$('.js-tiers').append(
        this.tierFieldsTemplate({
          baseField: {
            value: base
          },
          valueField: {
            name: this.tierInputName(base),
            value: value
          }
        })
      );
    }
  },

  events: {
    'click .js-add-tier': 'onAdd',
    'click .js-remove-tier': 'onRemove',
    'change .js-base-input': 'onChange'
  },

  tierInputName: function(base) {
    return this.formPrefix + "[calculator_attributes][preferred_tiers][" + base + "]";
  },

  onAdd: function(event) {
    event.preventDefault();
    this.$('.js-tiers').append(
      this.tierFieldsTemplate({
        valueField: {
          name: null
        }
      })
    );
  },

  onRemove: function(event) {
    event.preventDefault();
    $(event.target).parents('.tier').remove();
  },

  onChange: function(event) {
    var valueInput = $(event.target).parents('.tier').find('.js-value-input');
    valueInput.attr('name', this.tierInputName($(event.target).val()));
  }
});
