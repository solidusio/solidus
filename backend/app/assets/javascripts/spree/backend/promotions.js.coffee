window.initProductActions = ->
  # Add classes on promotion items for design
  $(document).on 'mouseover', 'a.delete', (event) ->
    $(this).parent().addClass 'action-remove'

  $(document).on 'mouseout', 'a.delete', (event) ->
    $(this).parent().removeClass 'action-remove'

  $('#promotion-filters').find('.variant_autocomplete').variantAutocomplete()

  $('.calculator-fields').each ->
    $fields_container = $(this)
    $type_select = $fields_container.find('.type-select')
    $settings = $fields_container.find('.settings')
    $warning = $fields_container.find('.warning')
    originalType = $type_select.val()
    $warning.hide()
    $type_select.change ->
      if $(this).val() == originalType
        $warning.hide()
        $settings.show()
        $settings.find('input').removeProp 'disabled'
      else
        $warning.show()
        $settings.hide()
        $settings.find('input').prop 'disabled', 'disabled'

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

  #
  # Tiered Calculator
  #
  if $('.js-tiers').length
    calculatorName = $('.js-tiers').data('calculator')
    tierFieldsTemplate = HandlebarsTemplates["promotions/calculators/fields/#{calculatorName}"]
    originalTiers = $('.js-tiers').data('original-tiers')
    formPrefix = $('.js-tiers').data('form-prefix')

    tierInputName = (base) ->
      "#{formPrefix}[calculator_attributes][preferred_tiers][#{base}]"

    $.each originalTiers, (base, value) ->
      $('.js-tiers').append tierFieldsTemplate
        baseField:
          value: base
        valueField:
          name: tierInputName(base)
          value: value

    $(document).on 'click', '.js-add-tier', (event) ->
      event.preventDefault()
      $('.js-tiers').append tierFieldsTemplate(valueField: name: null)

    $(document).on 'click', '.js-remove-tier', (event) ->
      event.preventDefault()
      $(this).parents('.tier').remove()

    $(document).on 'change', '.js-base-input', (event) ->
      valueInput = $(this).parents('.tier').find('.js-value-input')
      valueInput.attr 'name', tierInputName($(this).val())

$ initProductActions
