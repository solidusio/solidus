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
    var totalAmount = 0;
    var selectedItems = [];
    var decimals = 0;
    var separator = Spree.t('currency_separator');
    var amount, decimalAmount;

    if(this.model.get('allSelected')) {
      selectedItems = $('.selectable');
    } else {
      selectedItems = $(this.model.attributes.selectedItems);
    }
    selectedItems.each(function(_, selectedItem){
      amount = $(selectedItem).data('price');
      decimalAmount = amount.toString().split(separator)[1] || '';
      decimals = Math.max(decimals, decimalAmount.length);

      totalAmount += parseFloat(amount);
    })

    return accounting.formatNumber(totalAmount, decimals, Spree.t('currency_delimiter'), separator);
  },
});

