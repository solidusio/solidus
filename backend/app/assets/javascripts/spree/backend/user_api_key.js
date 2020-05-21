Spree.ready(function() {
  var el = $('#user-api-key');

  if (el.length > 0) {
    var model = new Spree.Models.User({
      id: el.data('user-id'),
      apiKey: el.data('api-key'),
      isCurrentUser: el.data('is-current-user')
    });

    new Spree.Views.User.ApiKey({
      el: el,
      model: model
    });
  }
});
