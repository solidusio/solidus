Spree.Views.Tables.EditableTableRow = Backbone.View.extend
  events:
    "select2-open": "onEdit"
    "focus input": "onEdit"
    "click [data-action=save]": "onSave"
    "click [data-action=cancel]": "onCancel"
    'keyup input': 'onKeypress'

  initialize: ->
    @storeValues()

  onEdit: ->
    @$el.addClass('editing')

  onCancel: (e) ->
    e.preventDefault()
    @$el.removeClass("editing")
    @restoreOriginalValues()

  onSave: (e) ->
    e.preventDefault()

    Spree.ajax @$el.find('.actions [data-action=save]').attr('href'),
      data: @$el.find('select, input').serialize()
      dataType: 'json'
      method: 'put'
      success: (response) =>
        @$el.removeClass("editing")
        @storeValues()
      error: (response) =>
        show_flash 'error', response.responseJSON.error

  ENTER_KEY: 13
  ESC_KEY: 27

  onKeypress: (e) ->
    key = e.keyCode || e.which
    switch key
      when @ENTER_KEY then @onSave(e)
      when @ESC_KEY then @onCancel(e)

  storeValues: ->
    $(":input", @$el).each ->
      $input = $(this)
      $input.data 'original-value', $input.val()

  restoreOriginalValues: ->
    $(":input", @$el).each ->
      $input = $(this)
      originalValue = $input.data('original-value')
      $input.val(originalValue).change()
