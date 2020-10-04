Spree.Views.Order.DetailsTotal = Backbone.View.extend({
  initialize: function() {
    this.listenTo(this.model, "change", this.render);
    this.render()
  },

  render: function() {
    var lineItemCount = this.model.get("line_items").length
    this.$el.toggleClass('hidden', !lineItemCount)
    this.$('.order-total').text(this.model.get("display_total"))
  }
})
