Spree.Views.User.ApiKey = Backbone.View.extend({
  initialize: function(options) {
    this.localeOptsObj = { scope: 'admin.users.edit' };
    this.listenTo(this.model, 'change', this.render);
    this.render();
  },

  events: {
    'click .clear-key-btn': 'onClear',
    'click .regenerate-key-btn': 'onRegenerate',
    'click .generate-key-btn': 'onGenerate'
  },

  template: HandlebarsTemplates['users/api_key'],

  render: function() {
    var renderAttr = {
      apiKey: this.model.get('apiKey'),
      isCurrentUser: this.model.get('isCurrentUser'),
      localeOpts: {
        hash: this.localeOptsObj
      }
    };
    this.$el.html(this.template(renderAttr));
    return this;
  },

  onClear: function(e) {
    e.preventDefault();
    if (confirm(Spree.t('confirm_clear_key', this.localeOptsObj))) {
      this.model.clearKey();
    }
  },

  onRegenerate: function(e) {
    e.preventDefault();
    if (confirm(Spree.t('confirm_regenerate_key', this.localeOptsObj))) {
      this.model.generateKey();
    }
  },

  onGenerate: function(e) {
    e.preventDefault();
    this.model.generateKey();
  }
});
