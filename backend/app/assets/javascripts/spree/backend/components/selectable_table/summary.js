Backbone.on('selectableTable:init', function(selectableTable){
  if(selectableTable.$el.find('.selectable').length > 0) {
    var tr = document.createElement('tr')
    new Spree.Views.Tables.SelectableTable.Summary({el: tr, model: selectableTable.model , columns: selectableTable.maxColumns()});
    selectableTable.$el.find('thead').prepend(tr);
  }
})
