# frozen_string_literal: true

# @component "ui/forms/text_area"
class SolidusAdmin::UI::Forms::TextArea::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # The text area component is used to render a textarea in a form.
  #
  # See the [`ui/forms/text_field`](../text_field) component for usage
  # instructions.
  def overview
    dummy_text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, urna eu aliquam ultricies, urna elit aliquam urna, eu aliquam urna elit euismod urna."
    render_with_template(
      locals: {
        sizes: current_component::SIZES.keys,
        variants: {
          "empty" => {
            value: nil, disabled: false, hint: nil, errors: {}
          },
          "filled" => {
            value: dummy_text, disabled: false, hint: nil, errors: {}
          },
          "with_hint" => {
            value: dummy_text, disabled: false, hint: "Max. 400 characters", errors: {}
          },
          "empty_with_error" => {
            value: nil, disabled: false, hint: nil, errors: { "empty_with_error" => ["can't be blank"] }
          },
          "filled_with_error" => {
            value: dummy_text, disabled: false, hint: nil, errors: { "filled_with_error" => ["is invalid"] }
          },
          "with_hint_and_error" => {
            value: dummy_text, disabled: false, hint: "Max. 400 characters", errors: { "with_hint_and_error" => ["is invalid"] }
          },
          "empty_disabled" => {
            value: nil, disabled: true, hint: nil, errors: {}
          },
          "filled_disabled" => {
            value: dummy_text, disabled: true, hint: nil, errors: {}
          },
          "with_hint_disabled" => {
            value: dummy_text, disabled: true, hint: "Max. 400 characters", errors: {}
          }
        }
      }
    )
  end

  # @param size select { choices: [s, m, l] }
  # @param label text
  # @param value text
  # @param hint text
  # @param errors text "Separate multiple errors with a comma"
  # @param placeholder text
  # @param disabled toggle
  def playground(size: :m, label: "Description", value: nil, hint: nil, errors: "", placeholder: "Placeholder", disabled: false)
    render_with_template(
      locals: {
        size: size.to_sym,
        field: label,
        value: value,
        hint: hint,
        errors: { label.dasherize => (errors.blank? ? [] : errors.split(",").map(&:strip)) },
        placeholder: placeholder,
        disabled: disabled
      }
    )
  end
end
