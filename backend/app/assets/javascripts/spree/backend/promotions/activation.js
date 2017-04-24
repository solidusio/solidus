Spree.PromotionActivationView = Backbone.View.extend({
  events: {
    "change [name=activation_type]": "render"
  },

  initialize: function(){
    this.render();
  },

  render: function(){
    var activation_type = this.$("[name=activation_type]:checked").val();
    this.$('[data-activation-type]').each(function(){
      var selected = ($(this).data('activation-type') === activation_type);
      $(this).find(':input').prop("disabled", !selected);
      $(this).toggle(selected);
    });
  }
});

Spree.ready(function(){
  if($("#js_promotion_activation").length) {
    new Spree.PromotionActivationView({
      el: $("#js_promotion_activation")
    });
  }
});
