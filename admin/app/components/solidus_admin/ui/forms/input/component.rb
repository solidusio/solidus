# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Input::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: "form-control-sm px-3 py-1.5 body-small",
    m: "form-control-md px-3 py-1.5 body-small",
    l: "form-control-lg px-3 py-1.5 body-text"
  }.freeze

  HEIGHTS = {
    s: "h-7",
    m: "h-9",
    l: "h-12"
  }.freeze

  MULTILINE_HEIGHTS = {
    s: %w[min-h-[84px]],
    m: %w[min-h-[108px]],
    l: %w[min-h-[144px]],
  }.freeze

  TYPES = Set.new(%i[
    text
    password
    number
    email
    tel
    url
    search
    color
    date
    datetime-local
    month
    week
    time
  ]).freeze

  def initialize(tag: :input, size: :m, error: nil, **attributes)
    raise ArgumentError, "unsupported tag: #{tag}" unless %i[input textarea select].include?(tag)

    specialized_classes = []

    case tag
    when :input
      specialized_classes << "form-input"
      specialized_classes << HEIGHTS[size]
      if attributes[:type] && !TYPES.include?(attributes[:type])
        raise ArgumentError, "unsupported type attribute: #{attributes[:type]}"
      end
    when :textarea
      specialized_classes << "form-textarea"
      specialized_classes << MULTILINE_HEIGHTS[size]
    when :select
      if attributes[:multiple]
        specialized_classes << "form-multiselect"
        specialized_classes << MULTILINE_HEIGHTS[size]
      else
        specialized_classes << "form-select"
        specialized_classes << "bg-arrow-down-s-fill-gray-700 invalid:bg-arrow-down-s-fill-red-400 aria-invalid:bg-arrow-down-s-fill-red-400"
        specialized_classes << HEIGHTS[size]
      end
    end

    attributes[:class] = [
      %w[
        w-full
        text-black bg-white border border-gray-300 rounded-sm placeholder:text-gray-400
        hover:border-gray-500
        focus:ring focus:ring-gray-300 focus:ring-0.5 focus:bg-white focus:ring-offset-0 [&:focus-visible]:outline-none
        disabled:bg-gray-50 disabled:text-gray-500 disabled:placeholder:text-gray-300 disabled:cursor-not-allowed
        invalid:border-red-400 invalid:hover:border-red-400 invalid:text-red-400
        aria-invalid:border-red-400 aria-invalid:hover:border-red-400 aria-invalid:text-red-400
      ],
      SIZES[size],
      specialized_classes,
      attributes[:class],
    ].compact.join(" ")

    @tag = tag
    @size = size
    @error = error
    @attributes = attributes
  end

  def call
    if @tag == :select && @attributes[:choices]
      with_content options_for_select(@attributes.delete(:choices), @attributes.delete(:value))
    end

    tag.public_send(
      @tag,
      content,
      "data-controller": stimulus_id,
      "data-#{stimulus_id}-custom-validity-value": @error.presence,
      "data-action": "#{stimulus_id}#clearCustomValidity",
      **@attributes
    )
  end
end
