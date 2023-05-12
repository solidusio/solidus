namespace :solidus_admin do
  namespace :tailwindcss do
    require "tailwindcss-rails"

    def compile_file(path, name)
      Tempfile.new(name).tap do |file|
        path
          .then { |path| File.read(path) }
          .then { |content| ERB.new(content) }
          .then { |erb| erb.result }
          .then { |compiled_content| file.write(compiled_content) && file.rewind }
      end
    end

    def run(args = "")
      config_file = compile_file(
        SolidusAdmin::Engine.root.join("config", "solidus_admin", "tailwind.config.js.erb"),
        "tailwind.config.js"
      )
      stylesheet_file = compile_file(
        SolidusAdmin::Engine.root.join("app", "assets", "stylesheets", "solidus_admin", "application.tailwind.css.erb"),
        "application.tailwind.css"
      )

      system "#{Tailwindcss::Engine.root.join("exe/tailwindcss")} \
         -i #{stylesheet_file.path} \
         -o #{Rails.root.join("app/assets/builds/solidus_admin/tailwind.css")} \
         -c #{config_file.path} \
         #{args}"
    ensure
      config_file&.close && config_file&.unlink
      stylesheet_file&.close && stylesheet_file&.unlink
    end

    desc "Build Solidus Admin's TailwindCSS"
    task build: :environment do
      run
    end

    desc <<~DESC
      Watch and build Solidus Admin's Tailwind CSS on file changes

      It needs to be re-run when SolidusAdmin::Config's "tailwind_content" or "tailwind_stylesheets" settings are updated
    DESC
    task watch: :environment do
      run("-w")
    end
  end
end

if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance(["solidus_admin:tailwindcss:build"])
end
