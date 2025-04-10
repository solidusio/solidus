# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Input::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: "form-control-sm px-3 py-1.5 font-normal text-sm",
    m: "form-control-md px-3 py-1.5 font-normal text-sm",
    l: "form-control-lg px-3 py-1.5 font-normal text-base"
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
    search
    time
  ]).freeze

  def initialize(tag: :input, size: :m, error: nil, **attributes)
    raise ArgumentError, "unsupported tag: #{tag}" unless %i[input textarea].include?(tag)

    specialized_classes = []
    readonly_classes = "read-only:bg-gray-15 focus:read-only:bg-gray-15 focus:read-only:ring-0
      read-only:cursor-not-allowed read-only:focus:border-gray-300
      read-only:hover:border-gray-300 read-only:hover:focus:border-gray-300"

    case tag
    when :input
      specialized_classes << "form-input"
      specialized_classes << readonly_classes
      specialized_classes << HEIGHTS[size]
      if attributes[:type] && !TYPES.include?(attributes[:type])
        raise ArgumentError, "unsupported type attribute: #{attributes[:type]}"
      end
    when :textarea
      specialized_classes << "form-textarea"
      specialized_classes << readonly_classes
      specialized_classes << MULTILINE_HEIGHTS[size]
    end

    attributes[:class] = [
      %w[
        peer w-full
        text-black bg-white border border-gray-300 rounded-sm placeholder:text-gray-400
        hover:border-gray-500
        focus:ring focus:ring-gray-300 focus:ring-0.5 focus:bg-white focus:ring-offset-0 [&:focus-visible]:outline-none
        disabled:bg-gray-50 disabled:text-gray-500 disabled:placeholder:text-gray-300 disabled:cursor-not-allowed
        invalid:border-red-600 invalid:hover:border-red-600 invalid:text-red-600
        aria-invalid:border-red-600 aria-invalid:hover:border-red-600 aria-invalid:text-red-600
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
    if @tag == :textarea && @attributes[:value]
      with_content @attributes.delete(:value)
    end

    build_tag
  end

  private

  def build_tag
    args = [@tag]
    args << content unless void_element?(@tag)

    tag.public_send(*args, **tag_options)
  end

  def tag_options
    @tag_options ||= {
      "data-controller": "custom-validity",
      "data-custom-validity-error-message-value": @error.presence,
      **@attributes
    }
  end
end
