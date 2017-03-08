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
      state_id: this.$state_select.select2("val")
    })
  },

  updateStates: function() {
    this.stopListening(this.states);
    this.pending = true;
    var country_id = this.model.get("country_id");
    if (country_id) {
      this.states = new Spree.Collections.States([], {country_id: country_id});
      this.listenTo(this.states, "reset", this.onSync);
      this.states.fetch({reset: true});
    }
  },

  onSync: function() {
    this.pending = false;
    this.render();
  },

  render: function() {
    this.$state_select.empty().select2("destroy").hide();
    this.$state_input.hide();

    if (this.pending) {
      this.$state_select.show().select2().select2("disable");
    } else if (this.states.length) {
      var $state_select = this.$state_select;
      this.states.each(function(state) {
        $state_select.append(
          $('<option>').prop('value', state.id).text(state.get("name"))
        );
      })
      this.$state_select.val(this.model.get("state_id"))
      this.$state_select.show().select2().select2("enable");
    } else {
      this.$state_input.prop('disabled', false).show();
    }
  }
})
