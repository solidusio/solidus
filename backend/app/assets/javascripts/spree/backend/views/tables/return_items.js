Spree.Views.Tables.ReturnItems = Backbone.View.extend({
  initialize: function() {
    if(this.$el.hasClass('return-items-table')) {
      var tfoot = document.createElement('tfoot')
      new Spree.Views.Tables.SelectableTable.SumReturnItemAmount({el: tfoot, model: this.model});
      this.$el.append(tfoot);

      this.$el.find('input, select').not('.add-item').on('change', function(e) {
        $(this).closest('tr').find('input.add-item').prop('checked', true)
          .change();
      });
    }
  },
})

