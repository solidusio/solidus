# Skip if already in the gemfile
if Bundler.locked_gems.dependencies["solidus_auth_devise"]
  say_status :skipping, "solidus_auth_devise is already in the gemfile"
else
  bundle_command("add solidus_auth_devise")
end

if options[:auto_accept]
  migrations_flag = options[:migrate] ? "--auto-run-migrations" : "--skip-migrations"
end

generate "solidus:auth:install #{migrations_flag}"

append_file "db/seeds.rb", <<~RUBY
  Spree::Auth::Engine.load_seed
RUBY
