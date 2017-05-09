
#
# Tiered Calculator
#
TieredCalculatorView = Backbone.View.extend
  initialize: ->
    @calculatorName = @$('.js-tiers').data('calculator')
    @tierFieldsTemplate = HandlebarsTemplates["promotions/calculators/fields/#{@calculatorName}"]
    @originalTiers = @$('.js-tiers').data('original-tiers')
    @formPrefix = @$('.js-tiers').data('form-prefix')

    for base, value of @originalTiers
      @$('.js-tiers').append @tierFieldsTemplate
        baseField:
          value: base
        valueField:
          name: @tierInputName(base)
          value: value

  events:
    'click .js-add-tier': 'onAdd'
    'click .js-remove-tier': 'onRemove'
    'change .js-base-input': 'onChange'

  tierInputName: (base) ->
    "#{@formPrefix}[calculator_attributes][preferred_tiers][#{base}]"

  onAdd: (event) ->
    event.preventDefault()
    @$('.js-tiers').append @tierFieldsTemplate(valueField: name: null)

  onRemove: (event) ->
    event.preventDefault()
    $(event.target).parents('.tier').remove()

  onChange: (event) ->
    valueInput = $(event.target).parents('.tier').find('.js-value-input')
    valueInput.attr 'name', @tierInputName($(event.target).val())

initTieredCalculators = ->
  $('.js-tiered-calculator').each ->
    if !$(this).data('has-view')
      $(this).data('has-view', true)
      new TieredCalculatorView(el: this)

window.initPromotionActions = ->
  # Add classes on promotion items for design
  $(document).on 'mouseover', 'a.delete', (event) ->
    $(this).parent().addClass 'action-remove'

  $(document).on 'mouseout', 'a.delete', (event) ->
    $(this).parent().removeClass 'action-remove'

  $('#promotion-filters').find('.variant_autocomplete').variantAutocomplete()

  #
  # Option Value Promo Rule
  #
  if $('.promo-rule-option-values').length
    optionValueSelectNameTemplate = HandlebarsTemplates['promotions/rules/option_values_select']
    optionValueTemplate = HandlebarsTemplates['promotions/rules/option_values']

    addOptionValue = (product, values) ->
      paramPrefix = $('.promo-rule-option-values').find('.param-prefix').data('param-prefix')
      $('.js-promo-rule-option-values').append optionValueTemplate(
        productSelect: value: product
        optionValuesSelect: value: values
        paramPrefix: paramPrefix)
      optionValue = $('.js-promo-rule-option-values .promo-rule-option-value').last()
      optionValue.find('.js-promo-rule-option-value-product-select').productAutocomplete multiple: false
      optionValue.find('.js-promo-rule-option-value-option-values-select').optionValueAutocomplete productSelect: '.js-promo-rule-option-value-product-select'
      if product == null
        optionValue.find('.js-promo-rule-option-value-option-values-select').prop 'disabled', true
      return

    originalOptionValues = $('.js-original-promo-rule-option-values').data('original-option-values')
    if !$('.js-original-promo-rule-option-values').data('loaded')
      if $.isEmptyObject(originalOptionValues)
        addOptionValue null, null
      else
        $.each originalOptionValues, addOptionValue
    $('.js-original-promo-rule-option-values').data 'loaded', true
    $(document).on 'click', '.js-add-promo-rule-option-value', (event) ->
      event.preventDefault()
      addOptionValue null, null
      return
    $(document).on 'click', '.js-remove-promo-rule-option-value', ->
      $(this).parents('.promo-rule-option-value').remove()
      return
    $(document).on 'change', '.js-promo-rule-option-value-product-select', ->
      optionValueSelect = $(this).parents('.promo-rule-option-value').find('input.js-promo-rule-option-value-option-values-select')
      paramPrefix = $('.promo-rule-option-values').find('.param-prefix').data('param-prefix')
      optionValueSelect.attr 'name', optionValueSelectNameTemplate(product_id: $(this).val(), param_prefix: paramPrefix).trim()
      optionValueSelect.prop('disabled', $(this).val() == '').select2 'val', ''
      return

  initTieredCalculators()

Spree.ready(initPromotionActions)
