# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Checkbox::Component < SolidusAdmin::BaseComponent
  FONT_WEIGHTS = {
    normal: 'font-normal',
    semibold: 'font-semibold',
  }

  FONT_SIZES = {
    sm: 'text-sm',
  }

  renders_one :label_text, ->(text:, weight: :normal, size: :sm, **options) do
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

  renders_one :hint, ->(text:) do
    render component("ui/toggletip").new(text:)
  end

  def initialize(field_name:, checked:, size: :m, **attributes)
    @field_name = field_name
    @checked = !!checked
    @size = size
    @attributes = attributes
  end
end
