Spree.Views.Tables.EditableTableRow = Backbone.View.extend
  events:
    "select2-open": "onEdit"
    "focus input": "onEdit"
    "click [data-action=save]": "onSave"
    "click [data-action=cancel]": "onCancel"
    'keyup input': 'onKeypress'

  onEdit: (e) ->
    return if @$el.hasClass('editing')
    @$el.addClass('editing')

    @$el.find('input, select').each ->
      $input = $(this)
      $input.data 'original-value', $input.val()

  onCancel: (e) ->
    e.preventDefault()
    @$el.removeClass("editing")

    @$el.find('input, select').each ->
      $input = $(this)
      originalValue = $input.data('original-value')
      $input.val(originalValue).change()

  onSave: (e) ->
    e.preventDefault()

    Spree.ajax @$el.find('.actions [data-action=save]').attr('href'),
      data: @$el.find('select, input').serialize()
      dataType: 'json'
      method: 'put'
      success: (response) =>
        @$el.removeClass("editing")
      error: (response) =>
        show_flash 'error', response.responseJSON.error

  ENTER_KEY: 13
  ESC_KEY: 27

  onKeypress: (e) ->
    key = e.keyCode || e.which
    switch key
      when @ENTER_KEY then @onSave(e)
      when @ESC_KEY then @onCancel(e)
