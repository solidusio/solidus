#= require handlebars

Handlebars.registerHelper "t", (key)->
  if Solidus.translations[key]
    Solidus.translations[key]
  else
    console.error "No translation found for #{key}."
    key

