Spree.Views.Tables.ReturnItems = Backbone.View.extend({
  initialize: function() {
    if(this.$el.hasClass('return-items-table')) {
      var tfoot = document.createElement('tfoot')
      new Spree.Views.Tables.SelectableTable.SumReturnItemAmount({el: tfoot, model: this.model});
      this.$el.append(tfoot);
    }
  },
})
