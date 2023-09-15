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

  def initialize(
    field:,
    builder:,
    type: :text,
    size: :m,
    hint: nil,
    errors: nil,
    tip: nil,
    **attributes
  )
    @field = field
    @builder = builder
    @type = type
    @size = size
    @hint = hint
    @type = type
    @tip = tip
    @attributes = HashWithIndifferentAccess.new(attributes)
    @errors = errors || @builder.object&.errors
  end

  def call
    @attributes[:class] = [
      %w[
        form-input
        block px-3 py-1.5 w-full
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
    ).with_content(@builder.send(
      TYPES.fetch(@type),
      @field,
      @attributes,
    ))
  end
end
