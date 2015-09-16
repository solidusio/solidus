_.extend Spree.translations,
  please_choose_language: "<%= Spree.t(:'i18n.choose_language') %>"

$ ->
  $('#available_locales_').select2({placeholder: Spree.translations['please_choose_language']})
