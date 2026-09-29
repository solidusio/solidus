# frozen_string_literal: true

class SolidusAdmin::UI::Forms::SelectTaxons::Component < SolidusAdmin::BaseComponent
  extend SolidusAdmin::ComponentsHelper

  def initialize(form, method, choices, **attributes)
    @form = form
    @method = method
    @choices = choices
    @attributes = {
      src: SolidusAdmin::Engine.routes.url_helpers.pretty_names_taxons_path,
      value: choices.map(&:last),
      "data-option-label-field": :pretty_name
    }.merge(attributes)
  end

  def call
    object_name, object, label, errors =
      SolidusAdmin::UI::Forms::Field::Component.extract_form_details(
        @form,
        @form.object,
        @method
      )

    render component("ui/forms/select").new(
      label:,
      hint: nil,
      tip: nil,
      size: :m,
      name: "#{object_name}[#{@method}]#{"[]" if @attributes[:multiple].present?}",
      choices: @choices,
      value: object.try(@method),
      error: errors&.to_sentence&.capitalize,
      **@attributes
    )
  end
end
