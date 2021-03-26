$(function() {
  $('#currency_selector select').change(function() {
    var select = this;
    var form = this.form;
    Spree.ajax({
      url: Spree.pathFor('/orders/current_order_has_items'),
      success: function(data) {
        if (data['result'] && !confirm($(form).data('confirm-text'))) {
          $(select).val($(form).data('current-currency'));
        } else {
          form.submit();
        }
      }
    });
  });
});
