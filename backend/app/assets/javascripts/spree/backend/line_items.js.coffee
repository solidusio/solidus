editing = (e) ->
  e.preventDefault()
  $(e.delegateTarget).addClass('editing')

editingDone = (e) ->
  e.preventDefault()
  $(e.delegateTarget).removeClass('editing')

$(document).ready ->
  $('.line-item')
    .on('click', '.edit-line-item',   editing)
    .on('click', '.cancel-line-item', editingDone)

  #handle save click
  $('a.save-line-item').click (e) ->
    save = $ this
    line_item = $(this).closest('.line-item')
    e.delegateTarget = line_item
    line_item_id = save.data('line-item-id')
    quantity = parseInt(save.parents('tr').find('input.line_item_quantity').val())

    editingLineItemDone(e)
    adjustLineItem(line_item_id, quantity)

  # handle delete click
  $('a.delete-line-item').click (e) ->
    if confirm(Spree.translations.are_you_sure_delete)
      line_item = $(this).closest('.line-item')
      e.delegateTarget = line_item
      del = $(this);
      line_item_id = del.data('line-item-id');

      editingLineItemDone(e)
      deleteLineItem(line_item_id)

lineItemURL = (line_item_id) ->
  url = Spree.routes.orders_api + "/" + order_number + "/line_items/" + line_item_id + ".json"

adjustLineItem = (line_item_id, quantity) ->
  url = lineItemURL(line_item_id)
  Spree.ajax(
    type: "PUT",
    url: url,
    data:
      line_item:
        quantity: quantity
      token: Spree.api_key
  ).done (msg) ->
    window.Spree.advanceOrder()

deleteLineItem = (line_item_id) ->
  url = lineItemURL(line_item_id)
  Spree.ajax(
    type: "DELETE"
    url: Spree.url(url)
  ).done (msg) ->
    $('#line-item-' + line_item_id).remove()
    if $('.line-items tr.line-item').length == 0
      $('.line-items').remove()
    window.Spree.advanceOrder()
