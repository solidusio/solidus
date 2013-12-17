$ ->
  $('#locale-select select').change ->
    $.ajax(
      type: 'POST'
      url: $(this).data('href')
      data:
        locale: $(this).val()
    ).done ->
      window.location.reload()
