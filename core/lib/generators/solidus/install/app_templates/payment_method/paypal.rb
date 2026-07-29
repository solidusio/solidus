unless Bundler.locked_gems.dependencies["solidus_paypal_commerce_platform"]
  # The released gem uses the old enum syntax and breaks on recent Ruby/Rails, so install from GitHub.
  bundle_command "add solidus_paypal_commerce_platform --github solidusio/solidus_paypal_commerce_platform"
end

generate "solidus_paypal_commerce_platform:install --migrate=#{options[:migrate]}"
