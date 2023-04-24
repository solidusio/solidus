solidus = Bundler.locked_gems.dependencies['solidus']

if Bundler.locked_gems.dependencies['solidus_frontend']
  say_status :skipping, "solidus_frontend is already in the bundle", :blue
else
  bundle_command("add solidus_frontend")
end

# Disable solidus_bolt installation from solidus_frontend as it can be
# explicitly selected directly from the solidus installer.
with_env('SKIP_SOLIDUS_BOLT' => 'true') do
  generate 'solidus_frontend:install'
end
