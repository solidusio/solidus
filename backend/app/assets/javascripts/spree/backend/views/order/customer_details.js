Spree.Views.Order.CustomerDetails = Backbone.View.extend({
  initialize: function() {
    this.billAddressView =
      new Spree.Views.Order.Address({
        model: this.model.get("bill_address"),
        el: this.$('.js-billing-address')
      });

    this.shipAddressView =
      new Spree.Views.Order.Address({
        model: this.model.get("ship_address"),
        el: this.$('.js-shipping-address')
      });

    this.customerSelectView =
      new Spree.Views.Order.CustomerSelect({
        el: this.$('#customer_search')
      });
    this.listenTo(this.customerSelectView, "select", this.onSelectCustomer);

    this.onGuestCheckoutChanged();
    this.onChange();

    this.listenTo(this.model, "change", this.render)
    this.render()
  },

  events: {
    "click #guest_checkout_true": "onGuestCheckoutChanged",
    "click #order_use_billing": "onChange",
    "change #order_email": "onChange"
  },

  onGuestCheckoutChanged: function() {
    if(this.$('#guest_checkout_true').is(':checked')) {
      this.model.set({user_id: null})
    }
  },

  onChange: function() {
    this.model.set({
      use_billing: this.$('#order_use_billing').is(':checked'),
      email: this.$("#order_email").val()
    })
  },

  onSelectCustomer: function(customer) {
    this.model.set({
      email: customer.email,
      user_id: customer.id,
      bill_address: customer.bill_address
    })
  },

  render: function() {
    var user_id = this.model.get("user_id") || $("#user_id").val()
    this.$("#user_id").val(user_id);
    this.$('#guest_checkout_true')
      .prop("checked", !user_id);
    this.$('#guest_checkout_false')
      .prop("checked", !!user_id)
      .prop("disabled", !user_id);

    this.$('#shipping').toggleClass("hidden", !!this.model.get("use_billing"));
    this.$('#order_email').val(this.model.get("email"))
  }
})
