# frozen_string_literal: true

# @api private
class SolidusAdmin::UI::Forms::Guidance::Component < SolidusAdmin::BaseComponent
  def initialize(field:, builder:, hint:, errors:, disabled: false)
    @field = field
    @builder = builder
    @hint = hint
    @disabled = disabled
    @errors = errors || @builder.object&.errors || raise(ArgumentError, <<~MSG
      When the form builder is not bound to a model instance, you must pass an
      errors Hash (`{ field_name: [errors] }`) to the component.
    MSG
    )
  end

  def call
    return "" unless needed?

    tag.div(class: "mt-2") do
      hint_tag + error_tag
    end
  end

  def hint_tag
    return "".html_safe unless @hint

    tag.p(id: hint_id, class: "body-tiny #{hint_text_color_class}") do
      @hint
    end
  end

  def hint_text_color_class
    @disabled ? "text-gray-300" : "text-gray-500"
  end

  def hint_id
    "#{prefix}_hint"
  end

  def error_tag
    return "".html_safe unless errors?

    tag.p(id: error_id, class: "body-tiny text-red-400") do
      @errors[@field].map do |error|
        tag.span(class: "block") { error.capitalize }
      end.reduce(&:+)
    end
  end

  def errors?
    @errors[@field].present?
  end

  def error_id
    "#{prefix}_error"
  end

  def prefix
    "#{@builder.object_name}_#{@field}"
  end

  def aria_describedby
    "#{hint_id if @hint} #{error_id if errors?}"
  end

  def needed?
    @hint || errors?
  end
end
