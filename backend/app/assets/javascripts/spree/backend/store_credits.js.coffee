$(document).ready ->
  return unless $('#sc_memo_edit_form').length > 0

  $('#sc_memo_edit_form').bind('ajax:complete', (event, xhr, options) =>
    if xhr.status is 200
      newValue = $('#sc_memo_edit_form').find("[name='store_credit[memo]']").val()
      $('#memo-edit-row').data('original-value', newValue)
      $('#memo-display-row').find('.js-memo-text').text(newValue)
      hideEditMemoForm()
  )

  $('.js-edit-memo').on('click', (ev) =>
    ev.preventDefault()
    originalValue = $('#memo-edit-row').data('original-value')
    $('#sc_memo_edit_form').find("[name='store_credit[memo]']").val(originalValue)
    $('#memo-display-row').addClass('hidden')
    $('#memo-edit-row').removeClass('hidden')
  )

  $('.js-save-memo').on('click', (ev) ->
    ev.preventDefault()
    $('#sc_memo_edit_form').submit()
  )

  $('.js-cancel-memo').on('click', (ev) =>
    ev.preventDefault()
    hideEditMemoForm()
  )

  hideEditMemoForm = ->
    $('#memo-edit-row').addClass('hidden')
    $('#memo-display-row').removeClass('hidden')
