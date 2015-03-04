$(document).ready(function () {
  'use strict';

  $.each($('td.qty input'), function (i, input) {

    $(input).on('change', function () {

      var id = '#' + $(this).prop('id').replace('_quantity', '_id');

      Spree.ajax({
        url: "/admin/orders/" + $('input#order_number').val() + '/line_items/' + $(id).val(),
        method: "PUT",
        data: { "line_item": { "quantity": $(this).val() } },
        always: function (resp) {
          $('#order-form-wrapper').html(resp.responseText);
        }
      });
    });
  });
});
