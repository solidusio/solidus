Backbone.on('selectableTable:init', function(selectableTable){
  if(selectableTable.$el.hasClass('return-items-table')) {
    new Spree.Views.Tables.ReturnItems({el: selectableTable.el, model: selectableTable.model});
  }
})
