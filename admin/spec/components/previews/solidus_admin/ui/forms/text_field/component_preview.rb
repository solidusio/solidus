# frozen_string_literal: true

# @component "ui/forms/text_field"
class SolidusAdmin::UI::Forms::TextField::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # The text field component is used to render a text field in a form.
  #
  # It must be used within the block context yielded in the [`form_with`
  # ](https://api.rubyonrails.org/v5.1/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)
  # or
  # [`form_for`](https://api.rubyonrails.org/v5.1/classes/ActionView/Helpers/FormHelper.html#method-i-form_for)
  # helpers.
  #
  # When the form builder is not bound to a model instance, you must pass an
  # errors Hash to the component. For example:
  #
  # ```erb
  # <%= form_with(url: search_path, method: :get) do |form| %>
  #  <%= render components('ui/forms/text_field').new(
  #    form: form,
  #    field: :q,
  #    errors: params[:q].present? ? {} : {
  #      q: ["can't be blank"]
  #    }
  #  ) %>
  #  <%= form.submit "Search" %>
  # <% end %>
  # ```
  #
  # When the form builder is bound to a model instance, the component will
  # automatically fetch the errors from the model.
  #
  # ```erb
  # <%= form_with(model: @user) do |form| %>
  #   <%= render components('ui/forms/text_field').new(
  #     form: form,
  #     field: :name
  #   ) %>
  #   <%= form.submit "Save" %>
  # <% end %>
  def overview
    render_with_template(
      locals: {
        sizes: current_component::SIZES.keys,
        variants: {
          "empty" => {
            value: nil, disabled: false, hint: nil, errors: {}
          },
          "filled" => {
            value: "Alice", disabled: false, hint: nil, errors: {}
          },
          "with_hint" => {
            value: "Alice", disabled: false, hint: "No special characters", errors: {}
          },
          "empty_with_error" => {
            value: nil, disabled: false, hint: nil, errors: { "empty_with_error" => ["can't be blank"] }
          },
          "filled_with_error" => {
            value: "Alice", disabled: false, hint: nil, errors: { "filled_with_error" => ["is invalid"] }
          },
          "with_hint_and_error" => {
            value: "Alice", disabled: false, hint: "No special characters", errors: { "with_hint_and_error" => ["is invalid"] }
          },
          "empty_disabled" => {
            value: nil, disabled: true, hint: nil, errors: {}
          },
          "filled_disabled" => {
            value: "Alice", disabled: true, hint: nil, errors: {}
          },
          "with_hint_disabled" => {
            value: "Alice", disabled: true, hint: "No special characters", errors: {}
          }
        }
      }
    )
  end

  # @param size select { choices: [s, m, l] }
  # @param type select { choices: [color, date, datetime, email, month, number, password, phone, range, search, text, time, url, week] }
  # @param label text
  # @param value text
  # @param hint text
  # @param errors text "Separate multiple errors with a comma"
  # @param placeholder text
  # @param disabled toggle
  def playground(size: :m, type: :text, label: "Name", value: nil, hint: nil, errors: "", placeholder: "Placeholder", disabled: false)
    render_with_template(
      locals: {
        size: size.to_sym,
        type: type.to_sym,
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
