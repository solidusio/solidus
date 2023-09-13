# frozen_string_literal: true

class SolidusAdmin::UI::Forms::TextField::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: %w[leading-4 body-small],
    m: %w[leading-6 body-small],
    l: %w[leading-9 body-text]
  }.freeze

  TYPES = {
    color: :color_field,
    date: :date_field,
    datetime: :datetime_field,
    email: :email_field,
    month: :month_field,
    number: :number_field,
    password: :password_field,
    phone: :phone_field,
    range: :range_field,
    search: :search_field,
    text: :text_field,
    time: :time_field,
    url: :url_field,
    week: :week_field
  }.freeze

  # @param field [Symbol] the name of the field. Usually a model attribute.
  # @param builder [ActionView::Helpers::FormBuilder] the form builder instance.
  # @param type [Symbol] the type of the field. Defaults to `:text`.
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
    type: :text,
    size: :m,
    hint: nil,
    errors: nil,
    **attributes
  )
    @field = field
    @builder = builder
    @type = type
    @size = size
    @hint = hint
    @type = type
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

    tag.div(class: "w-full mb-6") do
      label_tag + field_tag(guidance) + guidance_tag(guidance)
    end
  end

  def field_tag(guidance)
    @builder.send(
      field_helper,
      @field,
      class: field_classes(guidance),
      **field_aria_describedby_attribute(guidance),
      **field_error_attributes(guidance),
      **@attributes.except(:class)
    )
  end

  def field_classes(guidance)
    %w[
      form-input
      block px-3 py-1.5 w-full
      text-black
      bg-white border border-gray-300 rounded-sm
      hover:border-gray-500
      placeholder:text-gray-400
      focus:border-gray-500 focus:shadow-[0_0_0_2px_#bbb] focus-visible:outline-none
      disabled:bg-gray-50 disabled:text-gray-300
    ] + field_size_classes + field_error_classes(guidance) + Array(@attributes[:class]).compact
  end

  def field_helper
    TYPES.fetch(@type)
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
