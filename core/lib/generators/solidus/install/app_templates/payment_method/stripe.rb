unless Bundler.locked_gems.dependencies['solidus_stripe']
  bundle_options = @selected_frontend == 'classic' ? "--version='< 5'" : "--version='~> 5.a'"
  bundle_command "add solidus_stripe #{bundle_options}"
end

generate 'solidus_stripe:install'
