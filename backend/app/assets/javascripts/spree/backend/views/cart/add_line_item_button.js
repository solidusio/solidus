Spree.Views.Cart.AddLineItemButton = Backbone.View.extend({
  initialize: function() {
    this.listenTo(this.collection, 'update', this.render);
    this.render();
  },

  events: {
    "click": "onClick"
  },

  onClick: function() {
    this.collection.push({});
  },

  render: function() {
    var isNew = function(item) { return item.isNew() };
    this.$el.prop("disabled", !this.collection.length || this.collection.some(isNew));
  }
});
