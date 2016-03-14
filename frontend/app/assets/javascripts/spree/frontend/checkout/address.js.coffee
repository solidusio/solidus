$ ->
  if $('#checkout_form_address').is('*')
    # Hidden by default to support browsers with javascript disabled
    $('.js-address-fields').show()

    $('#checkout_form_address').validate()

    getCountryId = (region) ->
      $('#' + region + 'country select').val()

    statesByCountry = {}

    updateState = (region) ->
      countryId = getCountryId(region)
      if countryId?
        unless statesByCountry[countryId]?
          $.get Spree.routes.states_search, {country_id: countryId}, (data) ->
            statesByCountry[countryId] =
              states: data.states
              states_required: data.states_required
            fillStates(region)
        else
          fillStates(region)

    fillStates = (region) ->
      countryId = getCountryId(region)
      data = statesByCountry[countryId]
      return unless data?

      statesRequired = data.states_required
      states = data.states

      statePara = $('#' + region + 'state')
      stateSelect = statePara.find('select')
      stateInput = statePara.find('input')
      stateSpanRequired = statePara.find('[id$="state-required"]')
      if states.length > 0
        selected = parseInt stateSelect.val()
        stateSelect.html ''
        statesWithBlank = [{ name: '', id: ''}].concat(states)
        $.each statesWithBlank, (idx, state) ->
          opt = $(document.createElement('option')).attr('value', state.id).html(state.name)
          opt.prop 'selected', true if selected is state.id
          stateSelect.append opt

        stateSelect.prop('disabled', false).show()
        stateInput.hide().prop 'disabled', true
        statePara.show()
        if statesRequired
          stateSelect.addClass('required')
          stateSpanRequired.show()
        else
          stateSelect.removeClass('required')
          stateSpanRequired.hide()
        stateInput.removeClass('required')
      else
        stateSelect.hide().prop 'disabled', true
        stateInput.show()
        if statesRequired
          stateSpanRequired.show()
          stateInput.addClass('required')
        else
          stateInput.val ''
          stateSpanRequired.hide()
          stateInput.removeClass('required')
        statePara.toggle(!!statesRequired)
        stateInput.prop('disabled', !statesRequired)
        stateSelect.removeClass('required')

    $('#bcountry select').change ->
      updateState 'b'

    $('#scountry select').change ->
      updateState 's'

    updateState 'b'

    order_use_billing = $('input#order_use_billing')
    order_use_billing.change ->
      update_shipping_form_state order_use_billing

    update_shipping_form_state = (order_use_billing) ->
      if order_use_billing.is(':checked')
        $('#shipping .inner').hide()
        $('#shipping .inner input, #shipping .inner select').prop 'disabled', true
      else
        $('#shipping .inner').show()
        $('#shipping .inner input, #shipping .inner select').prop 'disabled', false
        updateState('s')

    update_shipping_form_state order_use_billing
