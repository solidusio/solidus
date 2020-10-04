Spree.Views.Order.DetailsAdjustments = Backbone.View.extend({
  initialize: function() {
    this.listenTo(this.model, "change", this.render);
    this.render()
  },

  adjustmentTotals: function() {
    var totals = {};
    var collection = this.collection ? this.collection.chain() : _.chain([this.model]);
    collection
      .map(function(item) {
        return (item.get("adjustments") || [])
          .filter(function(adjustment) { return (adjustment.eligible === true); });
      })
      .flatten(true)
      .each(function(adjustment){
        var label = adjustment.label;

        /* Fixme: because this is done in JS, we only have floating point math */
        totals[label] = (totals[label] || 0);
        totals[label] += Number(adjustment.amount);
      });
    return totals;
  },

  render: function() {
    var model = this.model;
    var tbody = this.$('tbody');
    var adjustmentTotals = this.adjustmentTotals()

    tbody.empty();
    _.each(adjustmentTotals, function(amount, label) {
       var html = HandlebarsTemplates["orders/details_adjustment_row"]({
         label: label,
         amount: Spree.formatMoney(amount, model.get("currency"))
       });
       tbody.append(html);
    });

    this.$el.toggleClass("hidden", _.isEmpty(adjustmentTotals));
  }
})
