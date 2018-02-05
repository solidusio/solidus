Spree.ready(function() {
  $('.inline-editable-table tr').each(function() {
    Spree.Views.Tables.EditableTable.add($(this));
  });
});
