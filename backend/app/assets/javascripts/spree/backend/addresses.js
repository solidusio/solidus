//= require 'spree/backend/views/state_select'

Spree.ready(function() {
  "use strict";

  _.each(document.querySelectorAll('.js-addresses-form'), function(el) {
    var countrySelect = el.querySelector('.js-country_id');
    var model = new Backbone.Model({
      country_id: countrySelect.value
    });

    countrySelect.addEventListener('change', function() {
      model.set({
        country_id: countrySelect.value
      });
    });

    new Spree.Views.StateSelect({
      el: el,
      model: model
    });
  });
});
