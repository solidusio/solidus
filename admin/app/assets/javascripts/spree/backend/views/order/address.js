Spree.Views.Order.Address = Backbone.View.extend({
  initialize: function(options) {
    // read initial values from page
    this.onChange();

    this.render();
    this.listenTo(this.model, "change", this.render);

    this.stateSelect =
      new Spree.Views.StateSelect({
        model: this.model,
        el: this.$el
      });
  },

  events: {
    "change": "onChange",
  },

  onChange: function() {
    this.model.set(this.getValues())
  },

  eachField: function(callback){
    var view = this;
    var fields = ["firstname", "lastname", "company", "address1", "address2",
      "city", "zipcode", "phone", "country_id"];
    _.each(fields, function(field) {
      var el = view.$('[name$="[' + field + ']"]');
      if (el.length) callback(field, el);
    });
  },

  getValues: function() {
    var attributes = {};
    this.eachField(function(name, el) {
      attributes[name] = el.val();
    });
    return attributes;
  },

  render: function() {
    var model = this.model;
    this.eachField(function(name, el) {
      el.val(model.get(name))
    })
  }
});
