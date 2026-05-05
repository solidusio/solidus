window.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById('checkout_form_address')) {
    // Hidden by default to support browsers with javascript disabled
    document.querySelectorAll('.js-address-fields')
      .forEach(field => field.style.display = 'block');

    const statesCache = {};

    function updateState(stateContainer, countryId) {
      if (statesCache[countryId]) {
        fillStates(stateContainer, countryId);
        return;
      }

      fetch(`${Solidus.routes.states_search}?country_id=${countryId}`)
        .then(response => response.json())
        .then(data => {
          statesCache[countryId] = {
            states: data.states,
            states_required: data.states_required
          };
          fillStates(stateContainer, countryId);
        });
    };

    function fillStates(stateContainer, countryId) {
      const stateData = statesCache[countryId];

      if (!stateData) {
        return;
      }

      const statesRequired = stateData.states_required;
      const states = stateData.states;

      const stateSelect = stateContainer.querySelector('select');
      const stateInput = stateContainer.querySelector('input');

      if (states.length > 0) {
        const selected = parseInt(stateSelect.value);
        stateSelect.innerHTML = '';
        const statesWithBlank = [{ name: '', id: ''}].concat(states);
        statesWithBlank.forEach(state => {
          const selectOption = document.createElement('option');
          selectOption.value = state.id;
          selectOption.innerHTML = state.name;
          if (selected === state.id) {
            selectOption.setAttribute('selected', true);
          }
          stateSelect.appendChild(selectOption);
        })
        stateSelect.style.display = 'block';
        stateSelect.removeAttribute('disabled');
        stateInput.style.display = 'none';
        stateInput.setAttribute('disabled', true);
        stateContainer.style.display = 'block';
        if (statesRequired) {
          stateSelect.classList.add('required');
          stateContainer.classList.add('field-required');
        } else {
          stateSelect.classList.remove('required');
          stateContainer.classList.remove('field-required');
        }
        stateInput.classList.remove('required');
      } else {
        stateSelect.style.display = 'none';
        stateSelect.setAttribute('disabled', true);
        stateInput.style.display = 'block';
        if (statesRequired) {
          stateContainer.classList.add('field-required');
          stateInput.classList.add('required');
        } else {
          stateInput.value = '';
          stateContainer.classList.remove('field-required');
          stateInput.classList.remove('required');
        }
        stateContainer.style.display = !!statesRequired ? 'block' : 'none';
        if (!statesRequired) {
          stateInput.setAttribute('disabled', true);
        } else {
          stateInput.removeAttribute('disabled');
        }
        stateSelect.classList.remove('required');
      }
    };

    document.querySelectorAll('.js-trigger-state-change').forEach(element => {
      element.addEventListener('change', () => {
        const stateContainer = document.querySelector(element.dataset.stateContainer);
        if (stateContainer) {
          const countryId = element.value;
          updateState(stateContainer, countryId);
        }
      });
    });

    document.querySelectorAll('.js-trigger-state-change:not([hidden])').forEach(element => {
      element.dispatchEvent(new Event('change'));
    });

    const orderUseBilling = document.getElementById('order_use_billing');
    orderUseBilling.addEventListener('change', function() {
      update_shipping_form_state(orderUseBilling);
    });

    function update_shipping_form_state(order_use_billing) {
      const addressInputs = document.querySelectorAll('#shipping .address-inputs');
      const inputs = document.querySelectorAll('#shipping .address-inputs input');
      const selects = document.querySelectorAll('#shipping .address-inputs select');
      if (order_use_billing.checked) {
        addressInputs.forEach(addressInput => addressInput.style.display = 'none');
        inputs.forEach(input => input.setAttribute('disabled', true));
        selects.forEach(sel => sel.setAttribute('disabled', true));
      } else {
        addressInputs.forEach(addressInput => addressInput.style.display = 'block');
        inputs.forEach(input => input.removeAttribute('disabled'));
        selects.forEach(sel => sel.removeAttribute('disabled'));
        document.querySelector('#shipping .js-trigger-state-change').dispatchEvent(new Event('change'));
      }
    };

    update_shipping_form_state(orderUseBilling);
  }
});
