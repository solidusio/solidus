# frozen_string_literal: true

namespace :solidus_admin do
  namespace :tailwindcss do
    desc "Build Tailwind CSS"
    task build: :dummy_environment do
      require "solidus_admin"
      require "tailwindcss/commands"

      config_file = <<~JS
        const adminRoot = "#{SolidusAdmin::Engine.root}"
        const solidusAdmin = require(`${adminRoot}/config/tailwind.config.js`)

        module.exports = {
          // Read how to use TailwindCSS presets: https://tailwindcss.com/docs/presets.
          presets: [solidusAdmin],

          content: [
            // Include paths coming from SolidusAdmin.
            ...solidusAdmin.content,

            // Include paths to your own components.
            `${__dirname}/../../../../app/components/admin/**/*`,
            `${__dirname}/../../../../lib/components/admin/**/*`,
          ],
        }
      JS
      FileUtils.mkdir_p(DummyApp::Application.root.join("config"))
      File.write(DummyApp::Application.root.join("config/tailwind.config.js"), config_file)
      FileUtils.mkdir_p(DummyApp::Application.root.join("app/assets/stylesheets/solidus_admin"))
      FileUtils.cp(
        SolidusAdmin::Engine.root.join("app/assets/stylesheets/solidus_admin/application.tailwind.css"),
        DummyApp::Application.root.join("app/assets/stylesheets/solidus_admin/application.tailwind.css")
      )

      tailwindcss = Tailwindcss::Commands.executable

      tailwindcss_command = [
        tailwindcss,
        "--config", DummyApp::Application.root.join("config/tailwind.config.js"),
        "--input", DummyApp::Application.root.join("app/assets/stylesheets/solidus_admin/application.tailwind.css"),
        "--output", DummyApp::Application.root.join("assets/builds/solidus_admin/tailwind.css")
      ]

      sh tailwindcss_command.shelljoin
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

  Rake::Task[task_name].enhance(["solidus_admin:tailwindcss:build"])
end
