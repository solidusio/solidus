Spree.ready(function($) {
  if ($("#checkout_form_address").is("*")) {
    // Hidden by default to support browsers with javascript disabled
    $(".js-address-fields").show();

    var getCountryId = function(region) {
      return $("#" + region + "country select").val();
    };

    var statesByCountry = {};

    var updateState = function(region) {
      var countryId = getCountryId(region);
      if (countryId != null) {
        if (statesByCountry[countryId] == null) {
          $.get(
            Spree.pathFor('api/states'),
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

    var fillStates = function(region) {
      var countryId = getCountryId(region);
      var data = statesByCountry[countryId];
      if (data == null) {
        return;
      }
      var statesRequired = data.states_required;
      var states = data.states;
      var statePara = $("#" + region + "state");
      var stateSelect = statePara.find("select");
      var stateInput = statePara.find("input");
      if (states.length > 0) {
        var selected = parseInt(stateSelect.val());
        stateSelect.html("");
        var statesWithBlank = [
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
          statePara.addClass("field-required");
        } else {
          stateSelect.removeClass("required");
          statePara.removeClass("field-required");
        }
        stateInput.removeClass("required");
      } else {
        stateSelect.hide().prop("disabled", true);
        stateInput.show();
        if (statesRequired) {
          statePara.addClass("field-required");
          stateInput.addClass("required");
        } else {
          stateInput.val("");
          statePara.removeClass("field-required");
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

    var order_use_billing = $("input#order_use_billing");
    order_use_billing.change(function() {
      update_shipping_form_state(order_use_billing);
    });

    var update_shipping_form_state = function(order_use_billing) {
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
