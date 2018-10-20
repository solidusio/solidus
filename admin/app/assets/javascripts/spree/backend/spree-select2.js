//= require solidus_admin/select2
Spree.ready(function() {
  // Make select beautiful
  $('select.select2').select2({
    allowClear: true,
    dropdownAutoWidth: true,
    minimumResultsForSearch: 8
  });
})
