display_locale_fields = () ->
  attr = $('#attr_list li.active a').data('attr')
  locales = $('select#locale').val()
  show = $("input[name='show-only']:checked").val()

  $('table#attr_fields tr').hide()

  for locale in locales
    do (locale) ->
      value = $('table#attr_fields tr.' + attr + '.' + locale + ' td.translation :input').val().replace /^\s+|\s+$/g, ""

      if show == 'incomplete'
        display = value == ''
      else if show == 'complete'
        display = value != ''
      else
        display = true

      if display
        $('table#attr_fields tr.' + attr + '.' + locale).show()

  if $('table#attr_fields tr:visible').length == 0 and show != 'all'
    $('table#attr_fields tfoot tr').show()
    $('table#attr_fields tfoot td').html('No <strong>' + show + '</strong> translations for <strong>' + attr + '</strong>.')


$ ->
  $('#attr_list a').click ->
    $('#attr_list li').removeClass('active')
    $(this).parent().addClass('active')

    display_locale_fields()
    false

  $('select#locale').select2({placeholder: 'Please select a language.'})
  $('select#locale').change display_locale_fields
  $("input[name='show-only']").change display_locale_fields

