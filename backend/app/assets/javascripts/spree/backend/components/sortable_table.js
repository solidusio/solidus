//= require solidus_admin/Sortable
/* eslint no-unused-vars: "off" */

Spree.ready(function() {
  var sortable_tables = document.querySelectorAll('table.sortable');

  _.each(sortable_tables, function(table) {
    var url = table.getAttribute('data-sortable-link');
    var tbody = table.querySelector('tbody');
    var sortable = Sortable.create(tbody,{
      handle: ".handle",
      onEnd: function(e) {
        var positions = {};
        _.each(e.to.querySelectorAll('tr'), function(el, index) {
          var idAttr = el.id;
          if (idAttr) {
            var objId = idAttr.split('_').slice(-1);
            if (!isNaN(objId)) {
              positions['positions['+objId+']'] = index + 1;
            }
          }
        });
        Spree.ajax({
          type: 'POST',
          dataType: 'json',
          url: url,
          data: positions,
        });
      }
    });
  });
});
