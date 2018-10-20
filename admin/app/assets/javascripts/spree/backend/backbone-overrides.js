Backbone.ajax = Spree.ajax;

Backbone._sync = Backbone.sync;

Backbone.sync = function(method, model, options) {
  var beforeSend = options.beforeSend;
  options.beforeSend = function(xhr) {
    var token = $('meta[name="csrf-token"]').attr('content');
    if (token) {
      xhr.setRequestHeader('X-CSRF-Token', token);
    }
    if (beforeSend) {
      return beforeSend.apply(this, arguments);
    }
  };

  if (options.data == null && model && model.paramRoot && (method === 'create' || method === 'update' || method === 'patch')) {
    options.contentType = "application/json";
    var data = {};
    data[model.paramRoot] = model.toJSON(options);
    options.data = JSON.stringify(data);
  }

  return Backbone._sync(method, model, options);
};
