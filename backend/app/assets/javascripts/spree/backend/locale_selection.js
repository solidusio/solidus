Spree.ready(function() {
  var localeSelect = document.querySelector('.js-locale-selection');
  if (!localeSelect) return;

  localeSelect.addEventListener('change', function() {
    Spree.ajax({
      type: "PUT",
      dataType: "json",
      url: Spree.pathFor("admin/locale/set"),
      data: { locale: localeSelect.value },
      success: function(data) {
        window.location.reload();
      }
    });
  });
});
