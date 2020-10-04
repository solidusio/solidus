Spree.Views.Stock.AddStockItem = Backbone.View.extend({
  initialize: function() {
    this.$countInput = this.$("[name='count_on_hand']");
    this.$locationSelect = this.$("[name='stock_location_id']");
    this.$backorderable = this.$("[name='backorderable']");
  },

  events: {
    "click .submit": "onSubmit",
    "submit form": "onSubmit",
    'input [name="count_on_hand"]': "onChange",
    'change [name="stock_location_id"]': "onChange",
    'click [name="backorderable"]': "onChange"
  },

  validate: function() {
    this.$locationSelect.toggleClass('error', !this.$locationSelect.val());
    this.$countInput.toggleClass('error', !this.$countInput.val());
    return this.$locationSelect.hasClass('error') || this.$countInput.hasClass('error');
  },

  onChange: function (event) {
    var $target = $(event.target)
    if ($target.val() !== '') $target.removeClass('error');
    this.$el.addClass('changed');
  },

  onSuccess: function() {
    var selectedStockLocationOption = this.$locationSelect.find('option:selected');
    var stockLocationName = selectedStockLocationOption.text().trim();
    selectedStockLocationOption.remove();
    var editView = new Spree.Views.Stock.EditStockItemRow({
      model: this.model,
      stockLocationName: stockLocationName
    });
    editView.$el.insertBefore(this.$el);
    editView.$el.addClass('stock-item-edit-row');
    this.model = new Spree.Models.StockItem({
      variant_id: this.model.get('variant_id'),
      stock_location_id: this.model.get('stock_location_id')
    });
    if (this.$locationSelect.find('option').length === 1) { // blank value
      this.remove();
    } else {
      this.$locationSelect.select2();
      this.$countInput.val("");
      this.$backorderable.prop("checked", false);
    }

    show_flash("success", Spree.translations.created_successfully);
  },

  onError: function(model, response, options) {
    show_flash("error", response.responseText);
  },

  onSubmit: function(ev) {
    ev.preventDefault();
    if (this.validate()) {
      return;
    }
    this.model.set({
      backorderable: this.$backorderable.prop("checked"),
      count_on_hand: this.$countInput.val(),
      stock_location_id: this.$locationSelect.val()
    });
    var options = {
      success: this.onSuccess.bind(this),
      error: this.onError.bind(this)
    };
    this.$el.removeClass('changed');
    this.model.save(null, options);
  }
});
