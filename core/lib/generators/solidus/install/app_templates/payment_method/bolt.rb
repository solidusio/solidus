plugin_name = PAYMENT_METHODS.fetch(@selected_payment_method)
plugin_generator_name = "#{plugin_name}:install"

if bundler_context.dependencies[plugin_name]
  say_status :skipping, "#{plugin_name} is already in the gemfile"
else
  gem plugin_name
  run_bundle
  run "spring stop" if defined?(Spring)
  generate "#{plugin_generator_name} --skip_migrations=true"
end
