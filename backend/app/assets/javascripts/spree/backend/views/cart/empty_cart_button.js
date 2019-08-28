Spree.Views.Cart.EmptyCartButton = Backbone.View.extend({
  initialize: function() {
    this.listenTo(this.collection, 'update', this.render);
    this.render();
  },

  events: {
    "click": "onClick"
  },

  onClick: function(e) {
    e.preventDefault()
    if (!confirm(Spree.translations.are_you_sure_delete)) {
      return;
    }

    this.model.empty({
      success: () => {
        this.collection.reset()
        this.collection.push({})
      }
    })
  },

  render: function() {
    var isNew = function (item) { return item.isNew() };
    this.$el.prop("disabled", !this.collection.length || this.collection.some(isNew));
  }
});
