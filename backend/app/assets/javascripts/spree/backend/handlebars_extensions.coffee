#= require handlebars
#= require spree/backend/translation

Handlebars.registerHelper "t", (key) ->
  Spree.t(key)

Handlebars.registerHelper "admin_url", ->
  Spree.pathFor("admin")
