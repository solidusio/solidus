$.fn.userAutocomplete = function () {
  'use strict';

  function formatUser(user) {
    return Select2.util.escapeMarkup(user.email);
  }

  this.select2({
    minimumInputLength: 1,
    multiple: true,
    initSelection: function (element, callback) {
      Spree.ajax({
        url: Spree.routes.users_api,
        data: {
          ids: element.val()
        },
        success: function(data) {
          callback(data.users);
        }
      });
    },
    ajax: {
      url: Spree.routes.users_api,
      datatype: 'json',
      params: { "headers": {  'Authorization': 'Bearer ' + Spree.api_key } },
      data: function (term) {
        return {
          q: {
            m: 'or',
            email_start: term,
            addresses_firstname_start: term,
            addresses_lastname_start: term
          }
        };
      },
      results: function (data) {
        return {
          results: data.users,
          more: data.current_page < data.pages
        };
      }
    },
    formatResult: formatUser,
    formatSelection: formatUser
  });
};

Spree.ready(function () {
  $('.user_picker').userAutocomplete();
});
