# frozen_string_literal: true

# This file is a Rails app template and should be loaded with `bin/rails `.

engine_root = File.expand_path("#{__dir__}/../..")
config_path = "config/solidus_admin/tailwind.config.js"
input_path = "app/assets/stylesheets/solidus_admin/application.tailwind.css"
output_path = "app/assets/builds/solidus_admin/tailwind.css"

unless bundle_command "show tailwindcss-rails"
  bundle_command "add tailwindcss-rails"
end

# Copy the Tailwind CSS main file.
create_file input_path, File.read("#{engine_root}/app/assets/stylesheets/solidus_admin/application.tailwind.css")

create_file config_path, <<~JS
  const { execSync } = require('child_process')
  const adminRoot = execSync('bundle show solidus_admin').toString().trim()
  const solidusAdmin = require(`${adminRoot}/config/tailwind.config.js`)

  module.exports = {
    // Read how to use TailwindCSS presets: https://tailwindcss.com/docs/presets.
    presets: [solidusAdmin],

    content: [
      // Include paths coming from SolidusAdmin.
      ...solidusAdmin.content,

      // Include paths to your own components.
      `${__dirname}/../../app/components/admin/**/*`,
    ],
  }
JS

create_file "lib/tasks/solidus_admin/tailwind.rake", <<~RUBY
  # frozen_string_literal: true

  namespace :solidus_admin do
    namespace :tailwindcss do
      root = Rails.root
      tailwindcss = Tailwindcss::Ruby.executable

      tailwindcss_command = [
        tailwindcss,
        "--config", root.join(#{config_path.to_s.inspect}),
        "--input", root.join(#{input_path.to_s.inspect}),
        "--output", root.join(#{output_path.to_s.inspect}),
      ]

      desc 'Build Tailwind CSS'
      task :build do
        sh tailwindcss_command.shelljoin
      end

      desc 'Watch Tailwind CSS'
      task :watch do
        sh (tailwindcss_command + ['--watch']).shelljoin
      end
    end
  end

  # Attach Tailwind CSS build to other tasks.
  %w[
    assets:precompile
    test:prepare
    spec:prepare
    db:test:prepare
  ].each do |task_name|
    next unless Rake::Task.task_defined?(task_name)

    Rake::Task[task_name].enhance(['solidus_admin:tailwindcss:build'])
  end
RUBY

if Rails.root.join(".gitignore").exist?
  append_file ".gitignore", "app/assets/builds/solidus_admin/"
end

unless Rails.root.join("Procfile.dev").exist?
  create_file "Procfile.dev", <<~YAML
    web: bin/rails server
  YAML
end

unless Rails.root.join("bin/dev").exist?
  create_file "bin/dev", <<~SH
    #!/usr/bin/env sh

    if ! gem list foreman -i --silent; then
      echo "Installing foreman..."
      gem install foreman
    fi

    # Default to port 3000 if not specified
    export PORT="${PORT:-3000}"

    exec foreman start -f Procfile.dev "$@"
  SH

  run "chmod +x bin/dev"
end

append_to_file "Procfile.dev", "admin_css: bin/rails solidus_admin:tailwindcss:watch\n"
