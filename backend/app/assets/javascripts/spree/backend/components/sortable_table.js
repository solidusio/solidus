//= require solidus_admin/Sortable
/* eslint no-unused-vars: "off" */

/* Check if string is valid UUID */
function isAValidUUID(str) {
  // https://stackoverflow.com/a/13653180/8170555
  const regexExp = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

  return regexExp.test(str);
}

Spree.SortableTable = {
  refresh: function() {
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
              if (!isNaN(objId) || isAValidUUID(objId)) {
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
  }
};

Spree.ready(Spree.SortableTable.refresh);

