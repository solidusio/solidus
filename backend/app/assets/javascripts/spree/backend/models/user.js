Spree.Models.User = Backbone.Model.extend({
  urlRoot: Spree.routes.users_api,

  apiKeyUrl: function() {
    return `${this.url()}/api_key`;
  },

  updateSpreeGlobal: function(value) {
    if (this.get('isCurrentUser')) {
      Spree.api_key = value;
    }
  },

  clearKey: function() {
    const model = this;
    fetch(this.apiKeyUrl(), {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${Spree.api_key}`
      }
    }).then(function(response) {
      if (response.ok) {
        model.set({ apiKey: null });
        show_flash('success', Spree.t('admin.api.key_cleared'));
        model.updateSpreeGlobal(null);
      }
    })
  },

  generateKey: function() {
    const model = this;
    fetch(this.apiKeyUrl(), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${Spree.api_key}`
      }
    }).then(function(response) {
      if (response.ok) return response.json()
    }).then(function({ spree_api_key }) {
      model.set({ apiKey: spree_api_key });
      show_flash('success', Spree.t('admin.api.key_generated'));
      model.updateSpreeGlobal(spree_api_key);
    })
  }
})
