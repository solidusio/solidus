$(function() {
  $('#locale_selector select').change(function() {
    this.form.submit();
  });
});
