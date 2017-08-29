class NumberFieldUpdater
  @hideReadOnly: (id) ->
    toggleReadOnly(id, false)
    resetInput(id)

  @showReadOnly: (id) ->
    toggleReadOnly(id, true)

  @showForm: (id) ->
    toggleForm(id, true)

  @hideForm: (id) ->
    toggleForm(id, false)

  @successHandler: (id, newNumber) ->
    $("#number-update-#{id} span").text(newNumber)
    @hideForm(id)
    @showReadOnly(id)

  toggleReadOnly = (id, show) ->
    toggleButtonVisibility('edit', id, show)
    toggleButtonVisibility('remove', id, show)
    cssDisplay = if show then 'block' else 'none'
    $("#number-update-#{id} span").css('display', cssDisplay)

  toggleForm = (id, show) ->
    toggleButtonVisibility('cancel', id, show)
    toggleButtonVisibility('save', id, show)
    cssDisplay = if show then 'block' else 'none'
    $("#number-update-#{id} input[type='number']").css('display', cssDisplay)

  toggleButtonVisibility = (buttonAction, id, show) ->
    cssDisplay = if show then 'inline-block' else 'none'
    $("[data-action='#{buttonAction}'][data-id='#{id}']").css('display', cssDisplay)

  resetInput = (id) ->
    tableCell = $("#number-update-#{id}")
    countText = tableCell.find('span').text().trim()
    tableCell.find("input[type='number']").val(countText)

Spree.NumberFieldUpdater = NumberFieldUpdater
