Spree.Views.Tables.SelectableTable.SumReturnItemAmount = Backbone.View.extend({
  initialize: function(options) {
    this.listenTo(this.model, 'change', this.render);

    this.render();
  },

  render: function() {
    var html = HandlebarsTemplates['tables/return_item_sum_amount']({
      total_pre_tax_refund: Spree.t("total_pre_tax_refund"),
      total_selected_item_amount: this.totalSelectedReturnItemAmount()
    });

    this.$el.html(html);
  },

  totalSelectedReturnItemAmount: function () {
    var totalAmount = 0.00;
    var selectedItems = [];

    if(this.model.get('allSelected')) {
      selectedItems = $('.selectable');
    } else {
      selectedItems = $(this.model.attributes.selectedItems);
    }
    selectedItems.each(function(_, selectedItem){
      totalAmount += $(selectedItem).data('price');
    })

    return totalAmount;
  },
});
