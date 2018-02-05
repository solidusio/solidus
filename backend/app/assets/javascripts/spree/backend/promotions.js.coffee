
initTieredCalculators = ->
  $('.js-tiered-calculator').each ->
    if !$(this).data('has-view')
      $(this).data('has-view', true)
      new Spree.Views.Calculators.Tiered(el: this)

window.initPromotionActions = ->
  # Add classes on promotion items for design
  $('#promotion-filters').on 'mouseover', 'a.delete', (event) ->
    $(this).parent().addClass 'action-remove'

  $('#promotion-filters').on 'mouseout', 'a.delete', (event) ->
    $(this).parent().removeClass 'action-remove'

  $('#promotion-filters').find('.variant_autocomplete').variantAutocomplete()

  $('.promo-rule-option-values').each ->
    if !$(this).data('has-view')
      $(this).data('has-view', true)
      new Spree.Views.Promotions.OptionValuesRule({ el: this })

  initTieredCalculators()

Spree.ready(initPromotionActions)
