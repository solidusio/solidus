Backbone.ajax = Spree.ajax

oldSync = Backbone.sync
Backbone.sync = (method, model, options) ->
  beforeSend = options.beforeSend
  options.beforeSend = (xhr) ->
    token = $('meta[name="csrf-token"]').attr('content')
    xhr.setRequestHeader('X-CSRF-Token', token) if token
    beforeSend.apply(this, arguments) if beforeSend

  # Allow for submitting requests the "rails way"
  # E.g. { model_name: model_attributes }
  # conditional and contentType are the same as vanilla backbone, save the
  # paramRoot check.
  postMethods = ['update', 'create', 'patch']
  if model?.paramRoot and !options.data and method in postMethods
    options.contentType = "application/json"
    data = {}
    data[model.paramRoot] = model.toJSON(options)
    options.data = JSON.stringify(data)

  oldSync method, model, options

