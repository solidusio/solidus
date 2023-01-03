unless Bundler.locked_gems.dependencies['solidus_frontend']
  say_status :warning, "Support for frontends other than `solidus_frontend` by `solidus_bolt` is still in progress.", :yellow
end

unless Bundler.locked_gems.dependencies['solidus_auth_devise']
  say_status :warning, "Running solidus_bolt without solidus_auth_devise is not supported.", :yellow
end

unless Bundler.locked_gems.dependencies['solidus_bolt']
  bundle_command 'add solidus_bolt'
end

generate 'solidus_bolt:install'

