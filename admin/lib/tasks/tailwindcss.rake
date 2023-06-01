namespace :solidus_admin do
  namespace :tailwindcss do
    require "solidus_admin/tailwindcss"

    desc "Build Solidus Admin's Tailwind's css"
    task build: :environment do
      SolidusAdmin::Tailwindcss.run
    end

    desc <<~DESC
      Watch and build Solidus Admin's Tailwind css on file changes

      It needs to be re-run whenever:

      - `SolidusAdmin::Config.tailwind_content` is updated
      - `SolidusAdmin::Config.tailwind_stylesheets` is updated
      - `bin/rails solidus_admin:tailwindcss:override_config` is run
      - `bin/rails solidus_admin:tailwindcss:override_stylesheet` is run
      - The override files are updated
    DESC
    task watch: :environment do
      SolidusAdmin::Tailwindcss.run("-w")
    end

    desc <<~DESC
      Override Solidus Admin's Tailwindcss configuration

      It copies the config file from the engine to the app, so it can be customized.
    DESC
    task override_config: :environment do
      SolidusAdmin::Tailwindcss.copy_file(
        SolidusAdmin::Tailwindcss.config_engine_path,
        SolidusAdmin::Tailwindcss.config_app_path
      )
    end

    desc <<~DESC
      Override Solidus Admin's Tailwind's stylesheet

      It copies the stylesheet file from the engine to the app, so it can be customized.
    DESC
    task override_stylesheet: :environment do
      SolidusAdmin::Tailwindcss.copy_file(
        SolidusAdmin::Tailwindcss.stylesheet_engine_path,
        SolidusAdmin::Tailwindcss.stylesheet_app_path
      )
    end
  end
end

if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance(["solidus_admin:tailwindcss:build"])
end
