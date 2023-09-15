# frozen_string_literal: true

class SolidusAdmin::UI::Forms::TextArea::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: %w[h-20 body-small],
    m: %w[h-28 body-small],
    l: %w[h-36 body-text]
  }.freeze

  def initialize(
    field:,
    builder:,
    size: :m,
    hint: nil,
    tip: nil,
    errors: nil,
    **attributes
  )
    @field = field
    @builder = builder
    @size = size
    @hint = hint
    @tip = tip
    @attributes = HashWithIndifferentAccess.new(attributes)
    @errors = errors || @builder.object&.errors
  end

  def call
    @attributes[:class] = [
      %w[
        block px-3 py-4 w-full
        text-black
        bg-white border border-gray-300 rounded-sm
        hover:border-gray-500
        placeholder:text-gray-400
        focus:border-gray-500 focus:shadow-[0_0_0_2px_#bbb] focus-visible:outline-none
        disabled:bg-gray-50 disabled:text-gray-300
      ],
      SIZES.fetch(@size),
      (%w[border-red-400 text-red-400] if @errors.present?),
      @attributes[:class],
    ].compact.join(" ")

    render component("ui/forms/field").new(
      label: @builder.object.class.human_attribute_name(@field),
      hint: @hint,
      tip: @tip,
      error: helpers.safe_join(@errors.messages_for(@field), tag.br).presence,
      **@attributes
    ).with_content(@builder.text_area(@field, **@attributes))
  end
end
