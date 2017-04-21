//= require jquery.payment
Spree.Views.Payment.EditCreditCard = Backbone.View.extend({
  initialize: function() {
    this.$(".cardNumber").payment('formatCardNumber');
    this.$(".cardExpiry").payment('formatCardExpiry');
    this.$(".cardCode").payment('formatCardCVC');

    this.render()
  },

  events: {
    'change [name=card]': 'render',
    'change .cardNumber': 'render'
  },

  render: function() {
    var isNew = (this.$('[name=card]:checked').val() === 'new') || (this.$('[name=card]').length == 0);
    this.$('.js-new-credit-card-form').toggleClass('hidden', !isNew)
    this.$('.js-new-credit-card-form :input').prop('disabled', !isNew)

    this.$(".ccType").val($.payment.cardType(this.$('.cardNumber').val()))
  }
})
