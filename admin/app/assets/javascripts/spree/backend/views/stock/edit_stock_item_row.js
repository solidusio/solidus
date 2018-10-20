Spree.Views.Stock.EditStockItemRow = Backbone.View.extend({
  tagName: 'tr',

  initialize: function(options) {
    this.stockLocationName = options.stockLocationName;
    this.negative = this.model.attributes.count_on_hand < 0;
    this.previousAttributes = _.clone(this.model.attributes);
    this.listenTo(this.model, 'sync', this.onSuccess);
    this.render();
  },

  events: {
    "click .submit": "onSubmit",
    "submit form": "onSubmit",
    "click .cancel": "onCancel",
    'input [name="count_on_hand"]': "countOnHandChanged"
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
    this.$count_on_hand_display = this.$('.count-on-hand-display');
    return this;
  },

  onEdit: function(ev) {
    ev.preventDefault();
    this.render();
  },

  onCancel: function(ev) {
    ev.preventDefault();
    this.model.set(this.previousAttributes);
    this.$el.removeClass('changed');
    this.render();
  },

  countOnHandChanged: function(ev) {
    var diff = parseInt(ev.currentTarget.value), newCount;
    if (isNaN(diff)) diff = 0;
    newCount = this.previousAttributes.count_on_hand + diff;
    ev.preventDefault();
    // Do not allow negative stock values
    if (newCount < 0) {
      ev.currentTarget.value = -1 * this.previousAttributes.count_on_hand;
      this.$count_on_hand_display.text(0);
    } else {
      this.model.set("count_on_hand", newCount);
      this.$count_on_hand_display.text(newCount);
    }
    this.$el.toggleClass('changed', diff !== 0);
  },

  onSuccess: function() {
    this.$el.removeClass('changed');
    this.previousAttributes = _.clone(this.model.attributes);
    this.render();
    this.$('[name="count_on_hand"]').focus();
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
      success: function() {
        show_flash("success", Spree.translations.updated_successfully);
      },
      error: this.onError.bind(this)
    };
    this.model.save({}, options);
  }
});
