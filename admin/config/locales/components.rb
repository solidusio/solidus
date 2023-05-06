require "yaml"
require "pathname"
namespace_root = File.expand_path "#{__dir__}/../../app/views"
components_root = File.expand_path "#{__dir__}/../../app/views/solidus_admin/components"

# Expects a component to have a file with the same basename and
# the .yml extension, holding translations scoped to the component's path.
#
# A component YML should look like this:
#
#   en:
#     hello: "Hello World!"
#
# And inside the component will be possible to call
#
#   t(".hello") # => "Hello World!"
#
Dir[p "#{components_root}/**/*.i18n.{yml,yaml}"].each.with_object({}) do |path, translations|
  relative_path = Pathname(path).relative_path_from(Pathname(namespace_root)).to_s
  component_translations = YAML.load_file(path, fallback: {})
  scopes = relative_path.sub(/\.i18n\.ya?ml/, "").gsub('/_', '/').split("/")

  component_translations.to_h.each do |locale, scoped_translations|
    translations[locale] ||= {}
    scopes.reduce(translations[locale]) do |nested_translations, scope|
      nested_translations[scope] ||= {}
    end
    translations[locale].dig(*scopes).merge! scoped_translations
  end
end.tap do |data|
  # Print the data when the file is being executed by itself
  puts data.to_yaml if $0 == __FILE__
end
