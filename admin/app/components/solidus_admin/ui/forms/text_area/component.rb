# frozen_string_literal: true

class SolidusAdmin::UI::Forms::TextArea::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: %w[h-20 body-small],
    m: %w[h-28 body-small],
    l: %w[h-36 body-text]
  }.freeze

  # @param field [Symbol] the name of the field. Usually a model attribute.
  # @param builder [ActionView::Helpers::FormBuilder] the form builder instance.
  # @param size [Symbol] the size of the field: `:s`, `:m` or `:l`.
  # @param hint [String, null] helper text to display below the field.
  # @param errors [Hash, nil] a Hash of errors for the field. If `nil` and the
  #   builder is bound to a model instance, the component will automatically fetch
  #   the errors from the model.
  # @param attributes [Hash] additional HTML attributes to add to the field.
  # @raise [ArgumentError] when the form builder is not bound to a model
  #  instance and no `errors` Hash is passed to the component.
  def initialize(
    field:,
    builder:,
    size: :m,
    hint: nil,
    errors: nil,
    **attributes
  )
    @field = field
    @builder = builder
    @size = size
    @hint = hint
    @attributes = HashWithIndifferentAccess.new(attributes)
    @errors = errors
  end

  def call
    guidance = component("ui/forms/guidance").new(
      field: @field,
      builder: @builder,
      hint: @hint,
      errors: @errors,
      disabled: @attributes[:disabled]
    )

    tag.div(class: "mb-6") do
      label_tag + field_tag(guidance) + guidance_tag(guidance)
    end
  end

  def field_tag(guidance)
    @builder.text_area(
      @field,
      class: field_classes(guidance),
      **field_aria_describedby_attribute(guidance),
      **field_error_attributes(guidance),
      **@attributes.except(:class)
    )
  end

  def field_classes(guidance)
    %w[
      block px-3 py-4 w-full
      text-black
      bg-white border border-gray-300 rounded-sm
      hover:border-gray-500
      placeholder:text-gray-400
      focus:border-gray-500 focus:shadow-[0_0_0_2px_#bbb] focus-visible:outline-none
      disabled:bg-gray-50 disabled:text-gray-300
    ] + field_size_classes + field_error_classes(guidance) + Array(@attributes[:class]).compact
  end

  def field_size_classes
    SIZES.fetch(@size)
  end

  def field_aria_describedby_attribute(guidance)
    return {} unless guidance.needed?

    {
      "aria-describedby": guidance.aria_describedby
    }
  end

  def field_error_classes(guidance)
    return [] unless guidance.errors?

    %w[border-red-400 text-red-400]
  end

  def field_error_attributes(guidance)
    return {} unless guidance.errors?

    {
      "aria-invalid": true
    }
  end

  def label_tag
    render component("ui/forms/label").new(field: @field, builder: @builder)
  end

  def guidance_tag(guidance)
    render guidance
  end
end
