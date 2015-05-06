editing = (e) ->
  e.preventDefault()
  $(e.delegateTarget).addClass('editing')

editingDone = (e) ->
  e.preventDefault()
  $(e.delegateTarget).removeClass('editing')

onSaveLineItem = (e) ->
  e.preventDefault()
  line_item = $(this).closest('.line-item')
  line_item_id = line_item.data('line-item-id')
  quantity = parseInt(line_item.find('input.line_item_quantity').val())
  adjustLineItem(line_item_id, quantity)
  editingDone(e)

onDeleteLineItem = (e) ->
  e.preventDefault()
  return unless confirm(Spree.translations.are_you_sure_delete)
  line_item = $(this).closest('.line-item')
  line_item_id = line_item.data('line-item-id');
  deleteLineItem(line_item_id)
  editingDone(e)

$(document).ready ->
  $('.line-item')
    .on('click', '.edit-line-item',   editing)
    .on('click', '.cancel-line-item', editingDone)
    .on('click', '.save-line-item',   onSaveLineItem)
    .on('click', '.delete-line-item', onDeleteLineItem)

lineItemURL = (id) ->
  "#{Spree.routes.line_items_api(order_number)}/#{id}.json"

adjustLineItem = (line_item_id, quantity) ->
  url = lineItemURL(line_item_id)
  Spree.ajax(
    type: "PUT",
    url: url,
    data:
      line_item:
        quantity: quantity
  ).done (msg) ->
    window.Spree.advanceOrder()

deleteLineItem = (line_item_id) ->
  url = lineItemURL(line_item_id)
  Spree.ajax(
    type: "DELETE"
    url: url
  ).done (msg) ->
    $('#line-item-' + line_item_id).remove()
    if $('.line-items tr.line-item').length == 0
      $('.line-items').remove()
    window.Spree.advanceOrder()
