# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Select::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: {
      select: %w[leading-4 body-small],
      arrow: %w[w-4 h-4]
    },
    m: {
      select: %w[leading-6 body-small],
      arrow: %w[w-5 h-5]
    },
    l: {
      select: %w[leading-9 body-text],
      arrow: %w[w-6 h-6]
    }
  }.freeze

  # @param field [Symbol] the name of the field. Usually a model attribute.
  # @param builder [ActionView::Helpers::FormBuilder] the form builder instance.
  # @param size [Symbol] the size of the field: `:s`, `:m` or `:l`.
  # @param choices [Array] an array of choices for the select box. All the
  #   formats valid for Rails' `select` helper are supported.
  # @param hint [String, null] helper text to display below the select box.
  # @param errors [Hash, nil] a Hash of errors for the field. If `nil` and the
  #  builder is bound to a model instance, the component will automatically fetch
  #  the errors from the model.
  # @param options [Hash] additional options to pass to Rails' `select` helper.
  # @param attributes [Hash] additional HTML attributes to add to the select box.
  # @raise [ArgumentError] when the form builder is not bound to a model
  #  instance and no `errors` Hash is passed to the component.
  def initialize(
    field:,
    builder:,
    size: :m,
    choices: [],
    hint: nil,
    errors: nil,
    options: {},
    attributes: {}
  )
    @field = field
    @builder = builder
    @size = size
    @choices = choices
    @hint = hint
    @options = options
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
      label_tag + field_wrapper_tag(guidance) + guidance_tag(guidance)
    end
  end

  def field_wrapper_tag(guidance)
    tag.div(
      class: "relative",
      "data-controller" => stimulus_id,
      "data-#{stimulus_id}-regular-class" => "text-black",
      "data-#{stimulus_id}-prompt-class" => "text-gray-400",
      "data-#{stimulus_id}-arrow-prompt-class" => "!fill-gray-500"
    ) do
      field_tag(guidance) + arrow_tag(guidance)
    end
  end

  def field_tag(guidance)
    @builder.select(
      @field,
      @choices,
      @options,
      class: field_classes(guidance),
      **field_aria_describedby_attribute(guidance),
      **field_error_attributes(guidance),
      **@attributes.except(:class).merge(
        "data-#{stimulus_id}-target" => "select",
        "data-action" => "#{stimulus_id}#refreshSelectClass"
      )
    )
  end

  def field_classes(guidance)
    %w[
      block px-3 py-1.5 w-full
      appearance-none
      text-black
      bg-white border border-gray-300 rounded-sm
      hover:border-gray-500
      focus:border-gray-500 focus:shadow-[0_0_0_2px_#bbb] focus-visible:outline-none
      disabled:bg-gray-50 disabled:text-gray-300
    ] + field_size_classes + field_error_classes(guidance) + Array(@attributes[:class]).compact
  end

  def field_size_classes
    SIZES.fetch(@size)[:select]
  end

  def field_error_classes(guidance)
    return [] unless guidance.errors?

    %w[border-red-400 text-red-400]
  end

  def field_aria_describedby_attribute(guidance)
    return {} unless guidance.needed?

    {
      "aria-describedby": guidance.aria_describedby
    }
  end

  def field_error_attributes(guidance)
    return {} unless guidance.errors?

    {
      "aria-invalid": true
    }
  end

  def arrow_tag(guidance)
    icon_tag(
      "arrow-down-s-fill",
      class: SIZES.fetch(@size)[:arrow] + [
        arrow_color_class(guidance)
      ] + %w[absolute right-3 top-1/2 translate-y-[-50%] pointer-events-none],
      "data-#{stimulus_id}-target" => "arrow"
    )
  end

  def arrow_color_class(guidance)
    if @attributes[:disabled]
      "fill-gray-500"
    elsif guidance.errors?
      "fill-red-400"
    else
      "fill-gray-700"
    end
  end

  def label_tag
    render component("ui/forms/label").new(field: @field, builder: @builder)
  end

  def guidance_tag(guidance)
    render guidance
  end
end
