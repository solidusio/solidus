auto_accept = options[:auto_accept] || ENV["AUTO_ACCEPT"]

with_log = ->(message, &block) {
  say_status :installing, "[solidus_starter_frontend] #{message}", :blue
  block.call
}

with_log["checking versions"] do
  if Rails.gem_version < Gem::Version.new("7.0")
    say_status :error, shell.set_color(
      "You are trying to install solidus_starter_frontend on an outdated Rails version.\n" \
      "This installation attempt has been aborted, please retry using at least Rails 7.", :bold
    ), :red
    exit 1
  end

  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.7")
    say_status :unsupported, shell.set_color(
      "You are installing solidus_starter_frontend on an outdated Ruby version.\n" \
      "Please keep in mind that some features might not work with it.", :bold
    ), :red
    exit 1 if auto_accept || no?("Do you wish to proceed?")
  end
end

# Copied from: https://github.com/mattbrictson/rails-template
# Copyright (c) 2023 Matt Brictson
# Licensed under the terms of the MIT License (MIT)
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
with_log["fetching remote templates"] do
  require "shellwords"
  require "securerandom"

  if __FILE__.match?(%r{\Ahttps?://})
    require "uri"
    url_path = URI.parse(__FILE__).path
    owner = url_path[%r{/([^/]+)/solidus_starter_frontend/}, 1]
    branch = url_path[%r{solidus_starter_frontend/(raw/)?(.+?)/template.rb}, 2]

    repo_source = "https://github.com/#{owner}/solidus_starter_frontend.git"
  else
    branch = nil
    repo_source = "file://#{File.dirname(__FILE__)}"
  end
  repo_dir = Rails.root.join("tmp/solidus_starter_frontend-#{SecureRandom.hex}").tap(&:mkpath).to_s

  git clone: [
    "--quiet",
    "--depth", "1",
    *(["--branch", branch] if branch),
    repo_source,
    repo_dir
  ].compact.shelljoin

  templates_dir = Pathname.new(repo_dir).join("templates")

  source_paths.unshift(templates_dir)
end

with_log["installing gems"] do
  unless Bundler.locked_gems.dependencies["solidus_auth_devise"]
    bundle_command "add solidus_auth_devise"
    generate "solidus:auth:install"
  end

  gem "responders"
  gem "solidus_support", ">= 0.12.0"
  gem "view_component", "~> 3.0"
  gem "tailwindcss-rails", "~> 3.0"

  gem_group :test do
    # We need to add capybara along with a javascript driver to support the provided system specs.
    # `rails new` will add the following gems for system tests unless `--skip-test` is provided.
    # We want to stick with them but we can't be sure about how the app was generated, so we'll
    # add them only if they're not already in the Gemfile.
    gem "capybara" unless Bundler.locked_gems.dependencies["capybara"]
    gem "selenium-webdriver" unless Bundler.locked_gems.dependencies["selenium-webdriver"]

    gem "capybara-screenshot", "~> 1.0"
    gem "database_cleaner", "~> 2.0"
  end

  gem_group :development, :test do
    gem "rspec-rails"
    gem "rails-controller-testing", "~> 1.0.5"
    gem "rspec-activemodel-mocks", "~> 1.1.0"

    gem "factory_bot", ">= 4.8"
    gem "factory_bot_rails"
    gem "ffaker", "~> 2.13"
    gem "rubocop", "~> 1.0"
    gem "rubocop-performance", "~> 1.5"
    gem "rubocop-rails", "~> 2.3"
    gem "rubocop-rspec", "~> 3.0"
  end

  run_bundle
end

with_log["installing files"] do
  directory "app", "app", verbose: auto_accept, force: auto_accept
  directory "public", "public"

  copy_file "config/importmap.rb"
  copy_file "config/initializers/solidus_auth_devise_unauthorized_redirect.rb"
  copy_file "config/routes/storefront.rb"
  copy_file "config/tailwind.config.js"
  create_file "app/assets/builds/tailwind.css"
  rake "tailwindcss:install"

  insert_into_file "config/environments/test.rb", "\n  config.assets.css_compressor = nil\n", after: "config.active_support.deprecation = :stderr"
  insert_into_file "config/environments/development.rb", "\n  config.assets.css_compressor = nil\n", after: "config.active_support.deprecation = :log"

  append_file "config/initializers/devise.rb", <<~RUBY
    Devise.setup do |config|
      config.parent_controller = 'StoreDeviseController'
      config.mailer = 'UserMailer'
    end
  RUBY

  application <<~RUBY
    if defined?(FactoryBotRails)
      initializer after: "factory_bot.set_factory_paths" do
        require 'spree/testing_support/factory_bot'

        # The paths for Solidus' core factories.
        solidus_paths = Spree::TestingSupport::FactoryBot.definition_file_paths

        # Optional: Any factories you want to require from extensions.
        extension_paths = [
          # MySolidusExtension::Engine.root.join("lib/my_solidus_extension/testing_support/factories"),
          # or individually:
          # MySolidusExtension::Engine.root.join("lib/my_solidus_extension/testing_support/factories/resource.rb"),
        ]

        # Your application's own factories.
        app_paths = [
          Rails.root.join('spec/factories'),
        ]

        FactoryBot.definition_file_paths = solidus_paths + extension_paths + app_paths
      end
    end
  RUBY

  # Allows to skip frontend specs generation from extensions CI pipelines
  if ENV.fetch("FRONTEND_SPECS", "all") == "all"
    directory "spec", verbose: false
  else
    # This file is always necessary in order to run frontend specs from extensions
    copy_file "spec/solidus_starter_frontend_spec_helper.rb", verbose: auto_accept, force: auto_accept
  end

  # In CI, the Rails environment is test. In that Rails environment,
  # `Solidus::InstallGenerator#setup_assets` adds `solidus_frontend` assets to
  # vendor. We'd want to forcefully replace those `solidus_frontend` assets with
  # SolidusStarterFrontend assets in CI.
  directory "vendor", verbose: false, force: Rails.env.test?
end

with_log["installing routes"] do
  solidus_mount_point = Pathname(app_path).join("config", "routes.rb").read[/mount Spree::Core::Engine, at: '([^']*)'/, 1]
  solidus_mount_point ||= "/"

  # The default output is very noisy
  shell.mute do
    route <<~RUBY
      scope(path: '#{solidus_mount_point}') { draw :storefront }
    RUBY
  end

  append_file "public/robots.txt", <<-ROBOTS.strip_heredoc
    User-agent: *
    Disallow: /checkout
    Disallow: /cart
    Disallow: /orders
    Disallow: /user
    Disallow: /account
    Disallow: /api
    Disallow: /password
  ROBOTS
end

with_log["patching asset files"] do
  append_file "config/initializers/assets.rb", "Rails.application.config.assets.precompile += ['solidus_starter_frontend_manifest.js']"
  append_file "config/initializers/assets.rb", "\nRails.application.config.assets.paths << Rails.root.join('app', 'assets', 'stylesheets', 'fonts')"
  gsub_file "app/assets/stylesheets/application.css", "*= require_tree", "* OFF require_tree"
end

with_log["setting up rspec"] do
  generate "rspec:install"
end

with_log["security advisory"] do
  message = <<~TEXT
    To receive security announcements concerning Solidus Starter
    Frontend, please subscribe to the Solidus Security mailing list
    (https://groups.google.com/forum/#!forum/solidus-security). The mailing
    list is very low traffic, and it receives the public notifications the
    moment the vulnerability is published. For more information, please check
    out https://solidus.io/security.
  TEXT

  say_status :RECOMMENDED, set_color(message.tr("\n", " "), :yellow), :yellow
end
