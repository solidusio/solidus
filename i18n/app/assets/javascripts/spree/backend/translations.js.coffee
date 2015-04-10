display_locale_fields = () ->
  attr    = $('#attr_list a.active').data('attr')
  locales = $('#locale').val()
  show    = $("select[name='show-only']").val()

  $('#attr_fields .panel').hide()

  for locale in locales
    do (locale) ->
      value = $('#attr_fields .panel.' + attr + '.' + locale + ' :input').val().replace /^\s+|\s+$/g, ""

      if show == 'incomplete'
        display = value == ''
      else if show == 'complete'
        display = value != ''
      else
        display = true

      if display
        $('#attr_fields .panel.' + attr + '.' + locale).show()

  if $('#attr_fields .panel:visible').length == 0 and show != 'all'
    $('#attr_fields .no-translations').show()


$ ->
  $('#attr_list a').click ->
    $('#attr_list a').removeClass('active')
    $(this).addClass('active')

    display_locale_fields()
    false

  $('#locale, #supported_locales_, #available_locales_').select2({placeholder: 'Please select a language.'})
  $('#locale').change ->
    display_locale_fields()

  $("select[name='show-only']").change ->
    display_locale_fields()

