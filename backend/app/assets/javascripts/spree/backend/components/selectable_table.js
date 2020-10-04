Spree.ready(function() {
  $('table.selectable-table').each(function() {
    new Spree.Views.Tables.SelectableTable({el: this})
  })
});
