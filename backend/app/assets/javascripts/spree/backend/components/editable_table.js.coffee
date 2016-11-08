Spree.ready ->
  $('.inline-editable-table tr').each ->
    Spree.Views.Tables.EditableTable.add $(this)
