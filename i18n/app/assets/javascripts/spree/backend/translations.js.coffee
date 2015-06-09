_.extend Spree.translations,
  please_choose_language: "<%= Spree.t(:choose_language, scope: 'i18n') %>"

$ ->
  $('#available_locales_').select2({placeholder: Spree.translations['please_choose_language']})
