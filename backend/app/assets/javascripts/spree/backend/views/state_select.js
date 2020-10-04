Spree.Views.StateSelect = Backbone.View.extend({
  initialize: function() {
    this.states = {} // null object

    this.$state_select = this.$('.js-state_id');
    this.$state_input = this.$('.js-state_name');

    // read initial values from page
    this.model.set({
      state_name: this.$state_input.val(),
      state_id: this.$state_select.val()
    })

    this.updateStates();
    this.listenTo(this.model, 'change:country_id', this.updateStates)
    this.render();
  },

  events: {
    "change .js-state_name": "onChange",
    "change .js-state_id": "onChange",
  },

  onChange: function() {
    this.model.set({
      state_name: this.$state_input.val(),
      state_id: this.$state_select.val()
    })
  },

  updateStates: function() {
    this.stopListening(this.states);
    var country_id = this.model.get("country_id");
    if (country_id) {
      this.states = Spree.Views.StateSelect.stateCache(country_id);
      this.listenTo(this.states, "sync", this.render);
    }
    this.render();
  },

  render: function() {
    this.$state_select.empty().hide().prop('disabled', true);
    this.$state_input.hide().prop('disabled', true);

    if (!this.model.get('country_id') || !this.states.fetched) {
      this.$state_select.show();
    } else if (this.states.length) {
      var $state_select = this.$state_select;
      this.states.each(function(state) {
        $state_select.append(
          $('<option>').prop('value', state.id).text(state.get("name"))
        );
      })
      this.$state_select.val(this.model.get("state_id"))
      this.$state_select.show().prop("disabled", false);
    } else {
      this.$state_input.show().prop('disabled', false);
    }
  }
})

Spree.Views.StateSelect.stateCache = _.memoize(function(country_id) {
  var states = new Spree.Collections.States([], {country_id: country_id})
  states.fetched = false;
  states.fetch({
    success: function() {
      states.fetched = true;
    }
  });
  return states;
});
