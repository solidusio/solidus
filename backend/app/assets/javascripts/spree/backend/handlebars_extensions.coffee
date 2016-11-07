#= require handlebars

# Resolves string keys with dots in a deeply nested object
# http://stackoverflow.com/a/22129960/4405214
resolveObject = (path, obj) ->
  path.split('.').reduce ((prev, curr) ->
    if prev then prev[curr] else undefined
  ), obj || self


Handlebars.registerHelper "t", (key) ->
  translation = resolveObject key, Spree.translations
  return translation if translation

  console.error "No translation found for #{key}."
  key

Handlebars.registerHelper "admin_url", ->
  Spree.pathFor("admin")
