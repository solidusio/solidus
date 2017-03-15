//= require handlebars
//= require spree/backend/translation

Handlebars.registerHelper("t", function(key, options) {
  return Spree.t(key, options.hash);
});

Handlebars.registerHelper("human_attribute_name", function(model, attr) {
  return Spree.human_attribute_name(model, attr);
});

Handlebars.registerHelper("admin_url", function() {
  return Spree.pathFor("admin")
});

Handlebars.registerHelper("concat", function() {
  return Array.prototype.slice.call(arguments, 0, -1).join('');
});
