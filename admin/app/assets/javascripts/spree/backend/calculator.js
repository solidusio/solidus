Spree.CalculatorEditView = Backbone.View.extend({
  events: {
    "change .js-calculator-type": "render",
  },

  initialize: function() {
    this.render();
  },

  render: function() {
    var selected_class = this.$('.js-calculator-type option:selected').val();
    this.$('.js-calculator-preferences').each(function() {
      var selected = ($(this).data('calculator-type') === selected_class);
      $(this).find(':input').prop("disabled", !selected);
      $(this).toggle(selected);
    });
  }
})

Spree.ready(function() {
  $('.js-calculator-fields').each(function() {
    new Spree.CalculatorEditView({
      el: this
    });
  });
});
