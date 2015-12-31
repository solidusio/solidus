$(document).ready ->
  return unless $('#sc_memo_edit_form').length > 0

  $('.js-edit-memo').on('click', (ev) =>
    ev.preventDefault()
    originalValue = $('#memo-edit-row').data('original-value')
    $('#sc_memo_edit_form').find("[name='store_credit[memo]']").val(originalValue)
    $('#memo-display-row').addClass('hidden')
    $('#memo-edit-row').removeClass('hidden')
  )

  $('.js-save-memo').on('click', (ev) ->
    ev.preventDefault()
    Spree.ajax(
      $('#sc_memo_edit_form').attr('url'), {
        data: $('#sc_memo_edit_form').serialize(),
        dataType: 'json',
        method: 'put',
        success: ( (response) =>
          newValue = $('#sc_memo_edit_form').find("[name='store_credit[memo]']").val()
          $('#memo-edit-row').data('original-value', newValue)
          $('#memo-display-row').find('.js-memo-text').text(newValue)
          hideEditMemoForm()
          show_flash('success', response.message)
        ),
        error: ( (xhr, status) =>
          show_flash('error', xhr.responseJSON.message)
        )
      }
    )
  )

  $('.js-cancel-memo').on('click', (ev) =>
    ev.preventDefault()
    hideEditMemoForm()
  )

  hideEditMemoForm = ->
    $('#memo-edit-row').addClass('hidden')
    $('#memo-display-row').removeClass('hidden')
