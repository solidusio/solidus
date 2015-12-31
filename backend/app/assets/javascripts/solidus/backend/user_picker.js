$.fn.userAutocomplete = function () {
  'use strict';

  this.select2({
    minimumInputLength: 1,
    multiple: true,
    initSelection: function (element, callback) {
      $.get(Solidus.routes.user_search, {
        ids: element.val()
      }, function (data) {
        callback(data);
      });
    },
    ajax: {
      url: Solidus.routes.user_search,
      datatype: 'json',
      params: { "headers": { "X-Solidus-Token": Solidus.api_key } },
      data: function (term) {
        return {
          q: term,
          token: Solidus.api_key
        };
      },
      results: function (data) {
        return {
          results: data
        };
      }
    },
    formatResult: function (user) {
      return user.email;
    },
    formatSelection: function (user) {
      return user.email;
    }
  });
};

$(document).ready(function () {
  $('.user_picker').userAutocomplete();
});
