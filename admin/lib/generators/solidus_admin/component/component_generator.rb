# frozen_string_literal: true

module SolidusAdmin
  class ComponentGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('templates', __dir__)

    argument :attributes, type: :array, default: [], banner: "attribute"

    class_option :html, type: :boolean, default: true
    class_option :i18n, type: :boolean, default: true
    class_option :js, type: :boolean, default: true
    class_option :spec, type: :boolean, default: true
    class_option :preview, type: :boolean, default: true

    def setup_inflections
      # This is needed because the generator won't run the initialization process,
      # in order to ensure that UI is not rendered as Ui we need to setup inflections
      # manually.
      SolidusAdmin::Engine.initializers.find { _1.name =~ /inflections/ }.run
    end

    def create_component_files
      template "component.html.erb", destination(".html.erb")
      unless options["html"]
        say_status :inline, destination(".html.erb"), :blue
        @inline_html = File.read(destination(".html.erb"))
        shell.mute { remove_file(destination(".html.erb")) }
      end
      template "component.rb", destination(".rb")
      template "component.yml", destination(".yml") if options["i18n"]
      template "component.js", destination(".js") if options["js"]
      template "component_spec.rb", destination("_spec.rb", root: "spec/components") if options["spec"]

      if options["preview"]
        preview_destination_path = destination("_preview.rb", root: "spec/components/previews")
        template "component_preview.rb", preview_destination_path
        template "component_preview_overview.html.erb", preview_destination_path.sub(/\.rb/, '/overview.html.erb')
      end
    end

    private

    def component_registry_id
      [class_path.presence, file_name].compact.join("/")
    end

    def destination(suffix, root: "app/components")
      File.join(root, class_path, file_name, "component#{suffix}")
    end

    def file_name
      @_file_name ||= super.sub(/_component\z/i, "")
    end

    def dom_class
      [class_path.presence, file_name].compact.join("/").tr("_", "-").gsub("/", "--")
    end

    def stimulus_controller_name
      dom_class
    end

    def stimulus_attributes
      ' data-controller="<%= stimulus_id %>"'
    end

    def initialize_signature
      return if attributes.blank?

      attributes.map { |attr| "#{attr.name}:" }.join(", ")
    end

    def initialize_body
      attributes.map { |attr| "@#{attr.name} = #{attr.name}" }.join("\n    ")
    end

    def preview_signature
      return if attributes.blank?

      signature = attributes.map { |attr| "#{attr.name}: #{attr.name.to_s.inspect}" }.join(", ")
      "(#{signature})"
    end

    def preview_playground_yard_tags
      return if attributes.blank?

      # See https://lookbook.build/guide/previews/params#input-types
      attributes.map { |attr| "# @param #{attr.name} text" }.join("\n  ")
    end

    def preview_playground_body
      render_signature = attributes.map { |attr| "#{attr.name}: #{attr.name}" }.join(", ")
      render_signature = "(#{render_signature})" if render_signature.present?

      "render component(#{component_registry_id.inspect}).new#{render_signature}"
    end

    def preview_overview_body
      component_registry_id = [class_path.presence, file_name].compact.join("/")

      "render component(#{component_registry_id.inspect}).new#{preview_signature}"
    end

    def attributes_html
      attributes.map { |attr| "<p> <%= @#{attr.name} %> </p>" }.join("\n  ")
    end

    def stimulus_html
      %{\n  <label>Your name: <input data-action="input->#{stimulus_controller_name}#typed"/></label>} +
        %{\n  <p>Hello <span data-#{stimulus_controller_name}-target="output"></span></p>}
    end

    def i18n_html
      "<%= t '.hello' %>"
    end

    def initialize_html
      [
        "<p>Add #{class_name} HTML here</p>",
        (attributes_html if attributes.present?),
        (stimulus_html if options["js"]),
        (i18n_html if options["i18n"]),
      ].compact.join("\n  ")
    end

    def inline_html(indent: '')
      @inline_html.gsub!(/^/, indent).strip
    end
  end
end
