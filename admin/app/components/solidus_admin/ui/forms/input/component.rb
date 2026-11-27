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
    l: %w[min-h-[144px]]
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
    hidden
  ]).freeze

  # Initializes a view component that will render an HTML input element.
  #
  # @param tag [Symbol] the HTML to build for input (default: +:input:+)
  # @param size [Symbol] the size of the input to create: either +:s, +:m+,
  #   or +:l+ (default: +:m+)
  # @param error [String] an error message for display to the user
  # @param prefix [String] a read-only prefix to prepend to the form field
  #   (for context or presentation)
  # @param attributes [Hash] a hash of attribute options to pass down to
  #  the form builder methods and affect render presentation
  def initialize(tag: :input, size: :m, error: nil, prefix: nil, **attributes)
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
      ("rounded-l-none" if prefix),
      attributes[:class]
    ].compact.join(" ")

    @tag = tag
    @size = size
    @error = error
    @prefix = prefix
    @attributes = attributes
  end

  def call
    if @tag == :textarea && @attributes[:value]
      with_content @attributes.delete(:value)
    end

    return build_tag unless @prefix

    tag.div(class: "flex w-full") do
      tag.span(@prefix, class: "flex items-center px-3 #{HEIGHTS[@size]} text-sm text-gray-500 bg-gray-15 border border-r-0 border-gray-300 rounded-l-sm whitespace-nowrap") + build_tag
    end
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
