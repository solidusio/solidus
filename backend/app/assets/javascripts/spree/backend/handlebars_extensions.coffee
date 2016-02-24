#= require handlebars

Handlebars.registerHelper "t", (key)->
  if Spree.translations[key]
    Spree.translations[key]
  else
    console.error "No translation found for #{key}."
    key

Handlebars.registerHelper "admin_url", ->
  Spree.pathFor("admin")
