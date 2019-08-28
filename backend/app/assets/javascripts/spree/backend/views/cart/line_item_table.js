Spree.Views.Cart.LineItemTable = Backbone.View.extend({
  initialize: function() {
    this.listenTo(this.collection, 'add', this.add);
    this.listenTo(this.collection, 'reset', this.reset);
  },

  add: function(line_item) {
    var view = new Spree.Views.Cart.LineItemRow({model: line_item});
    view.render();
    this.$el.append(view.el);
  },

  reset: function() {
    this.$el.empty();
  }
});
