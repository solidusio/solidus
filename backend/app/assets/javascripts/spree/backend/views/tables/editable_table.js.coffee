Spree.Views.Tables ||= {}

class Spree.Views.Tables.EditableTable
  @add: ($el) ->
    new Spree.Views.Tables.EditableTableRow el: $el

  @append: (html) ->
    $row = $(html)

    $('#images-table').removeClass('hidden').find('tbody').append($row)
    $row.find('.select2').select2()
    $('.no-objects-found').hide()

    @add($row)
