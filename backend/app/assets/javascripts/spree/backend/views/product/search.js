Spree.Views.Product.Search = Backbone.View.extend({
  initialize: function() {
    this.render();
  },

  events: {
    "change .js-with-discarded-input": "onChange"
  },

  onChange: function(e) {
    const withDiscarded = $(e.target).is(":checked");

    var keptInput = this.$el.find(".js-kept-variant-sku-input input");
    var allInput = this.$el.find(".js-all-variant-sku-input input");

    if (withDiscarded) {
      allInput.val(keptInput.val());
      keptInput.val("");
    } else {
      keptInput.val(allInput.val());
      allInput.val("");
    }

    allInput.prop("disabled", !withDiscarded)
    keptInput.prop("disabled", withDiscarded)

    this.render();
  },

  render: function() {
    var withDiscarded = this.$el.find(".js-with-discarded-input").is(":checked");

    var keptContainer = this.$el.find(".js-kept-variant-sku-input");
    var allContainer = this.$el.find(".js-all-variant-sku-input");

    if (withDiscarded) {
      keptContainer.hide();
      allContainer.show();
    } else {
      keptContainer.show();
      allContainer.hide();
    }
  },
});

