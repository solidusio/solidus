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

  def initialize(
    field:,
    builder:,
    size: :m,
    choices: [],
    hint: nil,
    errors: nil,
    tip: nil,
    options: {},
    attributes: {}
  )
    @field = field
    @builder = builder
    @size = size
    @choices = choices
    @hint = hint
    @tip = tip
    @options = options
    @attributes = HashWithIndifferentAccess.new(attributes)
    @errors = errors || @builder.object&.errors
  end

  def call
    @attributes[:class] = [
      %w[
        block px-3 py-1.5 w-full
        appearance-none
        text-black
        bg-white border border-gray-300 rounded-sm
        hover:border-gray-500
        focus:border-gray-500 focus:shadow-[0_0_0_2px_#bbb] focus-visible:outline-none
        disabled:bg-gray-50 disabled:text-gray-300
      ],
      SIZES.fetch(@size)[:select],
      @attributes[:class],
    ].compact.join(" ")

    render component("ui/forms/field").new(
      label: @builder.object.class.human_attribute_name(@field),
      hint: @hint,
      tip: @tip,
      error: helpers.safe_join(@errors.messages_for(@field), tag.br).presence,
      **@attributes
    ).with_content(@builder.select(
      @field,
      @choices,
      @options,
      "data-#{stimulus_id}-target" => "select",
      "data-action" => "#{stimulus_id}#refreshSelectClass",
      **@attributes,
    ))
  end
end
