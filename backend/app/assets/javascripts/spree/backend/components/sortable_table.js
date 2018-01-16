Spree.ready(function() {
  // Fix sortable helper
  var fixHelper = function(e, ui) {
      ui.children().each(function() {
          $(this).width($(this).width());
      });
      return ui;
  };

  var td_count = $(this).find('tbody tr:first-child td').length
  $('table.sortable tbody').sortable({
    handle: '.handle',
    helper: fixHelper,
    placeholder: 'ui-sortable-placeholder',
    update: function(event, ui) {
      $("#progress").show();
      var tableEl = $(ui.item).closest("table.sortable")
      var positions = {};
      $.each(tableEl.find('tbody tr'), function(position, obj){
        var idAttr = $(obj).prop('id');
        if (idAttr) {
          var objId = idAttr.split('_').slice(-1);
          if (!isNaN(objId)) {
            positions['positions['+objId+']'] = position+1;
          }
        }
      });
      Spree.ajax({
        type: 'POST',
        dataType: 'script',
        url: tableEl.data("sortable-link"),
        data: positions,
        success: function(data){ $("#progress").hide(); }
      });
    },
    start: function (event, ui) {
      // Set correct height for placehoder (from dragged tr)
      ui.placeholder.height(ui.item.height())
      // Fix placeholder content to make it correct width
      ui.placeholder.html("<td colspan='"+(td_count-1)+"'></td><td class='actions'></td>")
    },
    stop: function (event, ui) {
      var tableEl = $(ui.item).closest("table.sortable")
      // Fix odd/even classes after reorder
      tableEl.find("tr:even").removeClass("odd even").addClass("even");
      tableEl.find("tr:odd").removeClass("odd even").addClass("odd");
    }
  });
});
