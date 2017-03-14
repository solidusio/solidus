Spree.Views.Order.Address = Backbone.View.extend({
  initialize: function(options) {
    this.$(".js-country_id").select2();

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
      "city", "zipcode", "phone"];
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
    attributes['country_id'] = this.$(".js-country_id").select2("val")
    return attributes;
  },

  render: function() {
    var model = this.model;
    this.eachField(function(name, el) {
      el.val(model.get(name))
    })
    this.$(".js-country_id").select2("val", this.model.get("country_id"))
  }
});
