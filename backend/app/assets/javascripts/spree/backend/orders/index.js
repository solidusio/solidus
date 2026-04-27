//= require spree/backend/orders/edit
//= require spree/backend/orders/cart
$(document).ready(function() {
  $('.js-frontend-viewable-toggle').on('change', function() {
    var $checkbox = $(this);
    $.ajax({
      url: $checkbox.data('url'),
      type: 'PATCH',
      data: { order: { frontend_viewable: $checkbox.is(':checked') } },
      error: function() { 
        show_flash('error', 'Failed');
        $checkbox.prop('checked', !$checkbox.is(':checked'));
      }
    });
  });
});