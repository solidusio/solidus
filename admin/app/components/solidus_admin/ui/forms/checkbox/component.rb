# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Checkbox::Component < SolidusAdmin::BaseComponent
  FONT_WEIGHTS = {
    normal: 'font-normal',
    semibold: 'font-semibold',
  }.freeze

  FONT_SIZES = {
    xs: 'text-xs',
    s: 'text-sm',
  }.freeze

  renders_one :caption, ->(text:, weight: :normal, size: :s, **options) do
    tag.span(
      text,
      class: "
        #{FONT_WEIGHTS.fetch(weight)}
        #{FONT_SIZES.fetch(size)}
        #{options.delete(:classes)}
      ",
      **options
    )
  end

  renders_one :hint, ->(text:, position: :above) do
    render component("ui/toggletip").new(text:, position:)
  end

  def initialize(object_name:, method:, checked:, **attributes)
    @name = "#{object_name}[#{method}]"
    @checked = !!checked
    @attributes = attributes
  end
end
