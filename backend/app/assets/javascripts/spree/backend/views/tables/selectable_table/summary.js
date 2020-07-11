Spree.Views.Tables.SelectableTable.Summary = Backbone.View.extend({
  events: {
    'click input[name="select-all"]': 'onSelectedAll'
  },

  onSelectedAll: function(event) {
    this.model.set('allSelected', event.currentTarget.checked);
    if(event.currentTarget.checked == false) {
      this.model.set('selectedItems', []);
    }
  },

  initialize: function(options) {
    this.listenTo(this.model, 'change', this.render)

    this.colspan = options.columns - 1;

    this.render();
  },

  render: function() {
    var selectedItemLength = this.model.get('selectedItems').length;
    var all_items_selected = this.model.get('allSelected');

    var html = HandlebarsTemplates['tables/selectable_label']({
      colspan: this.colspan,
      item_selected_label: this.selectedItemLabel(all_items_selected, selectedItemLength),
      all_items_selected: all_items_selected
    });

    this.$el.html(html);
  },

  selectedItemLabel: function(all_selected, selected_item_length) {
    if(all_selected) {
      return Spree.t('items_selected.all');
    } else if(selected_item_length == 0) {
      return Spree.t('items_selected.none');
    } else if(selected_item_length == 1) {
      return Spree.t('items_selected.one');
    } else {
      return selected_item_length + " " + Spree.t('items_selected.custom');
    }
  }
});
