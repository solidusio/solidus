namespace :solidus_admin do
  namespace :tailwindcss do
    require "tailwindcss-rails"

    def run(args = "")
      compiled_config = SolidusAdmin::Engine.root.join("config", "solidus_admin", "tailwind.config.js.erb")
        .then { |path| File.read(path) }
        .then { |content| ERB.new(content) }
        .then { |erb| erb.result }

      Tempfile.create("tailwind.config.js") do |config_file|
        config_file.write(compiled_config) && config_file.rewind
        system "#{Tailwindcss::Engine.root.join("exe/tailwindcss")} \
         -i #{SolidusAdmin::Engine.root.join("app/assets/stylesheets/solidus_admin/application.tailwind.css")} \
         -o #{Rails.root.join("app/assets/builds/solidus_admin/tailwind.css")} \
         -c #{config_file.path} \
         #{args}"
      end
    end

    desc "Build Solidus Admin's TailwindCSS"
    task build: :environment do
      run
    end

    desc <<~DESC
      Watch and build Solidus Admin's Tailwind CSS on file changes

      It needs to be re-run when SolidusAdmin::Config.tailwind_content is updated
    DESC
    task watch: :environment do
      run("-w")
    end
  end
end

if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance(["solidus_admin:tailwindcss:build"])
end
