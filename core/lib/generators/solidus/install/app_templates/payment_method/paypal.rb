if @selected_frontend == 'classic'
  version = '< 1'
  migrations_flag = options[:migrate] ? '--auto-run-migrations' : '--skip-migrations'
else
  version = '~> 1.0'
  migrations_flag = "--migrate=#{options[:migrate]}"
end

unless Bundler.locked_gems.dependencies['solidus_paypal_commerce_platform']
  bundle_command "add solidus_paypal_commerce_platform --version='#{version}'"
end

generate "solidus_paypal_commerce_platform:install #{migrations_flag}"
