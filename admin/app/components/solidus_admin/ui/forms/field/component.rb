# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Field::Component < SolidusAdmin::BaseComponent
  def initialize(label:, hint: nil, tip: nil, error: nil, input_attributes: nil, **attributes)
    @label = label
    @hint = hint
    @tip = tip
    @error = [error] if error.present?
    @attributes = attributes
    @input_attributes = input_attributes

    raise ArgumentError, "provide either a block or input_attributes" if content? && input_attributes
  end

  def self.text_field(form, method, hint: nil, tip: nil, size: :m, **attributes)
    errors = form.object.errors.messages_for(method).presence

    new(
      label: form.object.class.human_attribute_name(method),
      hint: hint,
      tip: tip,
      error: errors,
      input_attributes: {
        name: "#{form.object_name}[#{method}]",
        tag: :input,
        size: size,
        value: form.object.public_send(method),
        error: (errors.to_sentence.capitalize if errors),
        **attributes,
      }
    )
  end

  def self.select(form, method, choices, hint: nil, tip: nil, size: :m, **attributes)
    errors = form.object.errors.messages_for(method).presence

    new(
      label: form.object.class.human_attribute_name(method),
      hint: hint,
      tip: tip,
      error: errors,
      input_attributes: {
        name: "#{form.object_name}[#{method}]",
        tag: :select,
        choices: choices,
        size: size,
        value: form.object.public_send(method),
        error: (errors.to_sentence.capitalize if errors),
        **attributes,
      }
    )
  end

  def self.text_area(form, method, hint: nil, tip: nil, size: :m, **attributes)
    errors = form.object.errors.messages_for(method).presence

    new(
      label: form.object.class.human_attribute_name(method),
      hint: hint,
      tip: tip,
      error: errors,
      input_attributes: {
        name: "#{form.object_name}[#{method}]",
        size: size,
        tag: :textarea,
        value: form.object.public_send(method),
        error: (errors.to_sentence.capitalize if errors),
        **attributes,
      }
    )
  end
end
