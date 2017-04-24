Spree.ready(function() {
  if ($("#new_payment").length) {
    new Spree.Views.Payment.New({
      el: $('#new_payment')
    })
  }

  $(".js-edit-credit-card").each(function() {
    new Spree.Views.Payment.EditCreditCard({ el: this })
  });
});
