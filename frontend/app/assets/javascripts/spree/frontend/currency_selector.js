$(function() {
  $('#currency_selector select').change(function() {
    var select = this;
    var form = this.form;
    if ($(form).data('needs-confirm') && !confirm($(form).data('confirm-text'))) {
      $(select).val($(form).data('current-currency'));
    } else {
      form.submit();
    }
  });
});
