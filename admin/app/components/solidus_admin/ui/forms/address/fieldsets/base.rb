# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Address::Fieldsets::Base < SolidusAdmin::BaseComponent
  renders_many :fields

  # @param extends [Array<Hash{Symbol => #call}, Symbol>] Pass an array of extensions to modify existing default
  #   fieldset with custom fields or override existing fields.
  #   If extension is a Hash, its key should be the name of the field and its value should be an object that responds
  #   to #call (e.g. proc or lambda) and returns a ViewComponent instance (or any object that responds to #render_in).
  #
  #   Since text inputs are often used as form fields, pass your field name as a Symbol and the component will render
  #   a text input for that field.
  # @example
  #   component("ui/forms/address/fieldsets/contact").new(
  #     extends: [
  #       title: -> { component("ui/forms/field").select(...) }, # this will add a custom :title select field
  #       name: -> { component("path/to/component").new }, # this will override existing default :name field
  #       :company, # this will add a text field for :company
  #     ],
  #     excludes: %i[phone reverse_charge], # this will exclude :phone and :reverse_charge from the fieldset
  #   )
  def initialize(addressable:, form_field_name:, extends: [], excludes: [])
    @addressable = addressable
    @form_field_name = form_field_name
    excludes = Array.wrap(excludes).map(&:to_sym)

    extended_fields_map = extends.reduce({}) do |acc, extension|
      if extension.is_a?(Hash)
        acc.merge!(extension)
      else
        acc[extension.to_sym] = -> { text_field_component(extension) }
        acc
      end
    end

    fields_map.merge(extended_fields_map).each do |field_name, renderable|
      with_field { render renderable.call } unless field_name.in?(excludes)
    end
  end

  def fields_map
    raise NotImplementedError, "fields_map must be implemented in #{self.class}"
  end

  def call
    safe_join(fields)
  end

  private

  def text_field_component(field_name)
    component("ui/forms/field").text_field(@form_field_name, field_name.to_sym, object: @addressable)
  end
end
