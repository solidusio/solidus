jQuery ->
  $('.track_inventory_checkbox').on 'click', ->
    $(@).siblings('.variant_track_inventory').val($(@).is(':checked'))
    $(@).parent('form').submit()
  $('.toggle_variant_track_inventory').on 'submit', ->
    Spree.ajax
      type: @method
      url: @action
      data: $(@).serialize()
    false
