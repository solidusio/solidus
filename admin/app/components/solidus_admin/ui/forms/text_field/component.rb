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
  # @param form [ActionView::Helpers::FormBuilder] the form builder instance.
  # @param type [Symbol] the type of the field. Defaults to `:text`.
  # @param size [Symbol] the size of the field: `:s`, `:m` or `:l`.
  # @param hint [String, null] helper text to display below the field.
  # @param errors [Hash, nil] a Hash of errors for the field. If `nil` and the
  #   form is bound to a model instance, the component will automatically fetch
  #   the errors from the model.
  # @param attributes [Hash] additional HTML attributes to add to the field.
  # @raise [ArgumentError] when the form builder is not bound to a model
  #  instance and no `errors` Hash is passed to the component.
  def initialize(field:, form:, type: :text, size: :m, hint: nil, errors: nil, **attributes)
    @field = field
    @form = form
    @type = type
    @size = size
    @hint = hint
    @type = type
    @attributes = attributes
    @errors = errors || @form.object&.errors || raise(ArgumentError, <<~MSG
      When the form builder is not bound to a model instance, you must pass an
      errors Hash (`field_name: [errors]`) to the component.
    MSG
    )
  end

  def call
    tag.div(class: "mb-6") do
      label_tag + field_tag + info_wrapper
    end
  end

  def info_wrapper
    tag.div(class: "mt-2") do
      hint_tag + error_tag
    end
  end

  def label_tag
    @form.label(@field, class: "block mb-0.5 body-tiny-bold")
  end

  def field_tag
    @form.send(
      field_helper,
      @field,
      class: field_classes,
      **field_aria_describedby_attribute,
      **field_error_attributes,
      **@attributes.except(:class)
    )
  end

  def field_classes
    %w[
      peer
      block px-3 py-1.5 w-full
      text-black text-black
      bg-white border border-gray-300 rounded-sm
      hover:border-gray-500
      placeholder:text-gray-400
      focus:border-gray-500 focus:shadow-[0_0_0_2px_#bbb] focus-visible:outline-none
      disabled:bg-gray-50 disabled:text-gray-300
    ] + field_size_classes + field_error_classes + Array(@attributes[:class]).compact
  end

  def field_helper
    TYPES.fetch(@type)
  end

  def field_size_classes
    SIZES.fetch(@size)
  end

  def field_error_classes
    return [] unless errors?

    %w[border-red-400 text-red-400]
  end

  def field_aria_describedby_attribute
    return {} unless @hint || errors?

    {
      "aria-describedby": "#{hint_id if @hint} #{error_id if errors?}"
    }
  end

  def field_error_attributes
    return {} unless errors?

    {
      "aria-invalid": true
    }
  end

  def hint_tag
    return "".html_safe unless @hint

    tag.p(id: hint_id, class: "body-tiny text-gray-500 peer-disabled:text-gray-300") do
      @hint
    end
  end

  def hint_id
    "#{id_prefix}_hint"
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
    "#{id_prefix}_error"
  end

  def id_prefix
    "#{@form.object_name}_#{@field}"
  end
end
