namespace :solidus_admin do
  namespace :tailwindcss do
    require "tailwindcss-rails"

    def config_app_path
      Rails.root.join("config", "solidus_admin", "tailwind.config.js.erb")
    end

    def config_engine_path
      SolidusAdmin::Engine.root.join("config", "solidus_admin", "tailwind.config.js.erb")
    end

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
        [config_app_path, config_engine_path].find(&:exist?),
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

      It needs to be re-run whenever:

      - `SolidusAdmin::Config.tailwind_content` is updated
      - `SolidusAdmin::Config.tailwind_stylesheets` is updated
      - `bin/rails solidus_admin:tailwindcss:override_config` is run
      - The override config file is updated
    DESC
    task watch: :environment do
      run("-w")
    end

    desc <<~DESC
      Override Solidus Admin's TailwindCSS configuration

      It copies the config file from the engine to the app, so it can be customized.
    DESC
    task override_config: :environment do
      src = config_engine_path
      dst = config_app_path
      FileUtils.mkdir_p(dst.dirname)
      FileUtils.cp(
        src,
        dst
      )
    end
  end
end

if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance(["solidus_admin:tailwindcss:build"])
end
