jQuery ->
  $('.stock_item_backorderable').on 'click', ->
    $(@).parent('form').submit()
  $('.toggle_stock_item_backorderable').on 'submit', ->
    Spree.ajax
      type: @method
      url: @action
      data: $(@).serialize()
    false
