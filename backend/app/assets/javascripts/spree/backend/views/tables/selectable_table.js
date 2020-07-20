Spree.Views.Tables.SelectableTable = Backbone.View.extend({
  events: {
    'change .selectable': 'onSelectedItem',
  },

  initialize: function() {
    this.model = new Backbone.Model({
      allSelected: false,
      selectedItems: []
    });

    this.listenTo(this.model, 'change', this.detectChanges)

    this.render();
    Backbone.trigger("selectableTable:init", this)
  },

  onSelectedItem: function(event) {
    var item = event.currentTarget;
    if(item.checked) {
      this.addItem(item)
    }else{
      this.$el.find('input[name="select-all"]').prop('checked', false);
      this.removeItem(item)
    }
  },

  addItem: function(item) {
    var items = _(this.model.get('selectedItems')).clone();
    if(items.indexOf(item) === -1) {
      items.push(item);
      this.model.set('selectedItems', items);
    }
  },

  removeItem: function(item) {
    var items = _(this.model.get('selectedItems')).clone();
    items.splice(items.indexOf(item), 1);
    this.model.set('selectedItems', items);
    this.model.set('allSelected', false);
  },

  maxColumns: function() {
    var max = 0;
    this.$el.find('tr').each(function(){
      var inTr = 0;
      $('td,th', this).each(function() { inTr += parseInt($(this).attr('colspan')) || 1 });
      max = Math.max(max,inTr);
    });

    return max;
  },

  detectChanges: function(model) {
    var selectableTable = this;
    if(model.changed.allSelected == true) {
      $('.selectable').each(function(_, item) { selectableTable.addItem(item) })
    }

    this.render();
  },

  render: function(){
    var model = this.model;

    this.$el.find('.selectable').each(function(_i, checkbox){
      checkbox.checked = model.get('allSelected') || model.get('selectedItems').includes(checkbox);
    })
  }
});
