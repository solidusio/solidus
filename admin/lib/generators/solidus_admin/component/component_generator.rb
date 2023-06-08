# frozen_string_literal: true

module SolidusAdmin
  class ComponentGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('templates', __dir__)

    argument :attributes, type: :array, default: [], banner: "attribute"

    class_option :html, type: :boolean, default: true
    class_option :i18n, type: :boolean, default: true
    class_option :js, type: :boolean, default: true
    class_option :spec, type: :boolean, default: true

    def create_component_files
      template "component.rb", destination(".rb")
      template "component.html.erb", destination(".html.erb") if options["html"]
      template "component.yml", destination(".yml") if options["i18n"]
      template "component.js", destination(".js") if options["js"]
      template "component_spec.rb", destination("_spec.rb", root: "spec/components") if options["spec"]
    end

    private

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
  end
end
