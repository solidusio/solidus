Spree.ready(function() {
  $('.store-credit-memo-row').each(function() {
    var row = this;
    var field = row.querySelector('[name="store_credit[memo]"]')
    var textDisplay = row.querySelector('.store-credit-memo-text')

    $(row).on('ajax:success', function(event, data) {
      row.classList.remove('editing');
      field.defaultValue = field.value;
      textDisplay.textContent = field.value;

      if (typeof data !== "undefined") {
        // we are using jquery_ujs
        message = data.message
      } else {
        // we are using rails-ujs
        message = event.detail[0].message
      }

      show_flash('success', message);
    }).on('ajax:error', function(event, xhr, status, error) {
      if (typeof xhr !== "undefined") {
        // we are using jquery_ujs
        message = xhr.responseJSON.message
      } else {
        // we are using rails-ujs
        message = event.detail[0].message
      }

      show_flash('error', message);
    });

    row.querySelector('.edit-memo').addEventListener('click', function() {
      row.classList.add('editing');
    });

    row.querySelector('.cancel-memo').addEventListener('click', function() {
      row.classList.remove('editing');
    });
  });
});
