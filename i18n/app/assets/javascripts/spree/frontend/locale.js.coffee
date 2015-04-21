$ ->
  $('#locale-select select').change ->
    @form.submit()
