# frozen_string_literal: true

require "tailwindcss-rails"

module SolidusAdmin
  # @api private
  module Tailwindcss
    module_function

    def run(args = "")
      config_file = compile_to_tempfile(
        [config_app_path, config_engine_path].find(&:exist?),
        "tailwind.config.js"
      )
      stylesheet_file = compile_to_tempfile(
        [stylesheet_app_path, stylesheet_engine_path].find(&:exist?),
        "application.tailwind.css"
      )

      system "#{::Tailwindcss::Engine.root.join('exe/tailwindcss')} \
         -i #{stylesheet_file.path} \
         -o #{Rails.root.join('app/assets/builds/solidus_admin/tailwind.css')} \
         -c #{config_file.path} \
         #{args}"
    ensure
      config_file&.close && config_file&.unlink
      stylesheet_file&.close && stylesheet_file&.unlink
    end

    def config_app_path
      Rails.root.join("config/solidus_admin/tailwind.config.js.erb")
    end

    def config_engine_path
      SolidusAdmin::Engine.root.join("config/solidus_admin/tailwind.config.js.erb")
    end

    def stylesheet_app_path
      Rails.root.join("app/assets/stylesheets/solidus_admin/application.tailwind.css.erb")
    end

    def stylesheet_engine_path
      SolidusAdmin::Engine.root.join("app/assets/stylesheets/solidus_admin/application.tailwind.css.erb")
    end

    def compile_to_tempfile(path, name)
      Tempfile.new(name).tap do |file|
        path
          .then { File.read(_1) }
          .then { |content| ERB.new(content) }
          .then { |erb| erb.result }
          .then { |compiled_content| file.write(compiled_content) && file.rewind }
      end
    end

    def copy_file(src, dst)
      FileUtils.mkdir_p(File.dirname(dst))
      FileUtils.cp(src, dst)
    end
  end
end
