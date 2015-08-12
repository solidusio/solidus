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
