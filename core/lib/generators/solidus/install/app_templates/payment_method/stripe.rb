unless Bundler.locked_gems.dependencies["solidus_stripe"]
  bundle_command "add solidus_stripe --version '~> 5.a'"
end

generate "solidus_stripe:install"
