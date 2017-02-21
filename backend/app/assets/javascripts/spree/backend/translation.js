(function() {
  // Resolves string keys with dots in a deeply nested object
  // http://stackoverflow.com/a/22129960/4405214
  var resolveObject = function(path, obj) {
    return path
      .split('.')
      .reduce(function(prev, curr) {
        return prev && prev[curr];
      }, obj || self);
  }

  Spree.t = function(key, options) {
    options = (options || {});
    if(options.scope) {
      key = options.scope + "." + key;
    }
    var translation = resolveObject(key, Spree.translations);
    if (translation) {
      return translation;
    } else {
      console.error("No translation found for " + key + ".");
      return key;
    }
  }

  Spree.human_attribute_name = function(model, attr) {
    return Spree.t("activerecord.attributes." + model + '.' + attr);
  }
})();
