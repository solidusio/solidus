Spree.Views.Tables.EditableTable = {
  add: function($el) {
    return new Spree.Views.Tables.EditableTableRow({
      el: $el
    });
  },

  append: function(html) {
    var $row = $(html);
    $('#images-table').removeClass('hidden').find('tbody').append($row);
    $row.find('.select2').select2();
    $('.no-objects-found').hide();
    return this.add($row);
  }
};
