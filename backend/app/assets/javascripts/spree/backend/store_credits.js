Spree.ready(function() {
  $('.store-credit-memo-row').each(function() {
    var row = this;
    var field = row.querySelector('[name="store_credit[memo]"]')
    var textDisplay = row.querySelector('.store-credit-memo-text')

    $(row).on('ajax:success', function(event, data) {
      row.classList.remove('editing');
      field.defaultValue = field.value;
      textDisplay.textContent = field.value;

      show_flash('success', data.message);
    }).on('ajax:error', function(event, xhr, status, error) {
      show_flash('error', xhr.responseJSON.message);
    });

    row.querySelector('.edit-memo').addEventListener('click', function() {
      row.classList.add('editing');
    });

    row.querySelector('.cancel-memo').addEventListener('click', function() {
      row.classList.remove('editing');
    });
  });
});
