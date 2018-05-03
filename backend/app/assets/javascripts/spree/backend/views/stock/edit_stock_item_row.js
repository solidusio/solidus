Spree.Views.Stock.EditStockItemRow = Backbone.View.extend({
  tagName: 'tr',

  initialize: function(options) {
    this.stockLocationName = options.stockLocationName;
    this.editing = false;
    this.negative = this.model.attributes.count_on_hand < 0;
    this.render();
  },

  events: {
    "click .edit": "onEdit",
    "click .submit": "onSubmit",
    "submit form": "onSubmit",
    "click .cancel": "onCancel"
  },

  template: HandlebarsTemplates['stock_items/stock_location_stock_item'],

  render: function() {
    var renderAttr = {
      stockLocationName: this.stockLocationName,
      editing: this.editing,
      negative: this.negative
    };
    _.extend(renderAttr, this.model.attributes);
    this.$el.attr("data-variant-id", this.model.get('variant_id'));
    this.$el.html(this.template(renderAttr));
    return this;
  },

  onEdit: function(ev) {
    ev.preventDefault();
    this.editing = true;
    this.render();
  },

  onCancel: function(ev) {
    ev.preventDefault();
    this.model.set(this.model.previousAttributes());
    this.editing = false;
    this.render();
  },

  onSuccess: function() {
    this.editing = false;
    this.render();
    show_flash("success", Spree.translations.updated_successfully);
  },

  onError: function(model, response, options) {
    show_flash("error", response.responseText);
  },

  onSubmit: function(ev) {
    ev.preventDefault();
    var backorderable = this.$('[name=backorderable]').prop("checked");
    var countOnHand = parseInt(this.$("input[name='count_on_hand']").val(), 10);

    this.model.set({
      count_on_hand: countOnHand,
      backorderable: backorderable
    });
    var options = {
      success: this.onSuccess.bind(this),
      error: this.onError.bind(this)
    };
    this.model.save({ force: true }, options);
  }
});
