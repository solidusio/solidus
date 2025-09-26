unless Bundler.locked_gems.dependencies["solidus_braintree"]
  bundle_command 'add solidus_braintree --version "~> 3.0"'
end

generate "solidus_braintree:install --migrate=#{options[:migrate]}"
