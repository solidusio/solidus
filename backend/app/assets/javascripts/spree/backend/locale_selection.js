Spree.ready(function() {
  var localeSelect = document.querySelector('.js-locale-selection');
  if (!localeSelect) return;

  localeSelect.addEventListener('change', function() {
    Spree.ajax({
      type: "PUT",
      dataType: "json",
      url: Spree.pathFor("admin/locale/set"),
      data: {
        switch_to_locale: localeSelect.value
      },
      success: function(data) {
        document.location.href = data.location;
      }
    });
  });
});
