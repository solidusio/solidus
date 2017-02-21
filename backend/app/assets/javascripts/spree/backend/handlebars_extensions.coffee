#= require handlebars
#= require spree/backend/translation

Handlebars.registerHelper "t", (key, options) ->
  Spree.t(key, options.hash)

Handlebars.registerHelper "human_attribute_name", (model, attr) ->
  Spree.human_attribute_name(model, attr)

Handlebars.registerHelper "admin_url", ->
  Spree.pathFor("admin")
