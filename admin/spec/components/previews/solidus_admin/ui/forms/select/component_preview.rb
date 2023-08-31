# frozen_string_literal: true

# @component "ui/forms/select"
class SolidusAdmin::UI::Forms::Select::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # The select component is used to render a select box in a form.
  #
  # See the [`ui/forms/text_field`](../text_field) component for usage
  # instructions.
  def overview
    choices = [
      ["Option 1", "option_1"],
      ["Option 2", "option_2"],
      ["Option 3", "option_3"]
    ]
    hint = "Select one of the options"
    render_with_template(
      locals: {
        sizes: current_component::SIZES.keys,
        choices: choices,
        variants: {
          "with_prompt" => {
            hint: nil, errors: {}, options: { prompt: "Select" }, attributes: {}
          },
          "selected" => {
            hint: nil, errors: {}, options: {}, attributes: {}
          },
          "with_hint" => {
            hint: hint, errors: {}, options: {}, attributes: {}
          },
          "with_prompt_and_error" => {
            hint: nil, errors: { "with_prompt_and_error" => ["can't be blank"] }, options: { prompt: "Select" }, attributes: {}
          },
          "selected_with_error" => {
            hint: nil, errors: { "selected_with_error" => ["is invalid"] }, options: {}, attributes: {}
          },
          "with_hint_and_error" => {
            hint: hint, errors: { "with_hint_and_error" => ["is invalid"] }, options: {}, attributes: {}
          },
          "with_prompt_disabled" => {
            hint: nil, errors: {}, options: { prompt: "Select" }, attributes: { disabled: true }
          },
          "selected_disabled" => {
            hint: nil, errors: {}, options: {}, attributes: { disabled: true }
          },
          "with_hint_disabled" => {
            hint: hint, errors: {}, options: {}, attributes: { disabled: true }
          }
        }
      }
    )
  end

  # @param size select { choices: [s, m, l] }
  # @param choices text "Separate multiple choices with a comma"
  # @param label text
  # @param selected text
  # @param hint text
  # @param errors text "Separate multiple errors with a comma"
  # @param prompt text
  # @param disabled toggle
  def playground(
    size: :m,
    choices: "Option 1, Option 2, Option 3",
    label: "Choose:",
    selected: "Option 1",
    hint: nil, errors: "",
    prompt: "Select",
    disabled: false
  )
    render_with_template(
      locals: {
        size: size.to_sym,
        choices: choices.split(",").map(&:strip).map { [_1, _1.parameterize] },
        field: label,
        selected: selected&.parameterize,
        hint: hint,
        errors: { label.dasherize => (errors.blank? ? [] : errors.split(",").map(&:strip)) },
        prompt: prompt,
        disabled: disabled
      }
    )
  end
end
