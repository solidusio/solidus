Spree.Views.Zones.Form = Backbone.View.extend({
  events: {
    'click [name="zone[kind]"]': 'render'
  },

  render: function() {
    var kind = this.$('[name="zone[kind]"]:checked').val() || 'state';
    this.$('[name="zone[kind]"]').val([kind]);

    $('#state_members').toggleClass('hidden', kind !== 'state');
    $('#state_members :input').prop('disabled', kind !== 'state');

    $('#country_members').toggleClass('hidden', kind !== 'country');
    $('#country_members :input').prop('disabled', kind !== 'country');
  }
})
