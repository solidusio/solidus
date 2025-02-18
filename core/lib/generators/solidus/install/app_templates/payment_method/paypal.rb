unless Bundler.locked_gems.dependencies["solidus_paypal_commerce_platform"]
  bundle_command "add solidus_paypal_commerce_platform --version='~> 1.0'"
end

generate "solidus_paypal_commerce_platform:install --migrate=#{options[:migrate]}"
