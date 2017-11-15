Spree.ready(function($) {
  var fillStates,
    getCountryId,
    order_use_billing,
    statesByCountry,
    updateState,
    update_shipping_form_state;
  if ($("#checkout_form_address").is("*")) {
    // Hidden by default to support browsers with javascript disabled
    $(".js-address-fields").show();
    getCountryId = function(region) {
      return $("#" + region + "country select").val();
    };
    statesByCountry = {};
    updateState = function(region) {
      var countryId;
      countryId = getCountryId(region);
      if (countryId != null) {
        if (statesByCountry[countryId] == null) {
          $.get(
            Spree.routes.states_search,
            {
              country_id: countryId
            },
            function(data) {
              statesByCountry[countryId] = {
                states: data.states,
                states_required: data.states_required
              };
              fillStates(region);
            }
          );
        } else {
          fillStates(region);
        }
      }
    };
    fillStates = function(region) {
      var countryId,
        data,
        selected,
        stateInput,
        statePara,
        stateSelect,
        stateSpanRequired,
        states,
        statesRequired,
        statesWithBlank;
      countryId = getCountryId(region);
      data = statesByCountry[countryId];
      if (data == null) {
        return;
      }
      statesRequired = data.states_required;
      states = data.states;
      statePara = $("#" + region + "state");
      stateSelect = statePara.find("select");
      stateInput = statePara.find("input");
      stateSpanRequired = statePara.find('[id$="state-required"]');
      if (states.length > 0) {
        selected = parseInt(stateSelect.val());
        stateSelect.html("");
        statesWithBlank = [
          {
            name: "",
            id: ""
          }
        ].concat(states);
        $.each(statesWithBlank, function(idx, state) {
          var opt;
          opt = $(document.createElement("option"))
            .attr("value", state.id)
            .html(state.name);
          if (selected === state.id) {
            opt.prop("selected", true);
          }
          stateSelect.append(opt);
        });
        stateSelect.prop("disabled", false).show();
        stateInput.hide().prop("disabled", true);
        statePara.show();
        if (statesRequired) {
          stateSelect.addClass("required");
          stateSpanRequired.show();
        } else {
          stateSelect.removeClass("required");
          stateSpanRequired.hide();
        }
        stateInput.removeClass("required");
      } else {
        stateSelect.hide().prop("disabled", true);
        stateInput.show();
        if (statesRequired) {
          stateSpanRequired.show();
          stateInput.addClass("required");
        } else {
          stateInput.val("");
          stateSpanRequired.hide();
          stateInput.removeClass("required");
        }
        statePara.toggle(!!statesRequired);
        stateInput.prop("disabled", !statesRequired);
        stateSelect.removeClass("required");
      }
    };
    $("#bcountry select").change(function() {
      updateState("b");
    });
    $("#scountry select").change(function() {
      updateState("s");
    });
    updateState("b");
    order_use_billing = $("input#order_use_billing");
    order_use_billing.change(function() {
      update_shipping_form_state(order_use_billing);
    });
    update_shipping_form_state = function(order_use_billing) {
      if (order_use_billing.is(":checked")) {
        $("#shipping .inner").hide();
        $("#shipping .inner input, #shipping .inner select").prop(
          "disabled",
          true
        );
      } else {
        $("#shipping .inner").show();
        $("#shipping .inner input, #shipping .inner select").prop(
          "disabled",
          false
        );
        updateState("s");
      }
    };
    update_shipping_form_state(order_use_billing);
  }
});
