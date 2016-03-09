//= require select2
jQuery(function($) {
  // Make select beautiful
  $('select.select2').select2({
    allowClear: true,
    dropdownAutoWidth: true,
    minimumResultsForSearch: 8
  });

  function format_taxons(taxon) {
    new_taxon = taxon.text.replace('->', '<i class="fa fa-arrow-right">')
    return new_taxon;
  }
})
