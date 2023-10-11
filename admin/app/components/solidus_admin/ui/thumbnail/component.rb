# frozen_string_literal: true

class SolidusAdmin::UI::Thumbnail::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: 'h-6 w-6',
    m: 'h-10 w-10',
    l: 'h-20 w-20',
  }.freeze

  def initialize(size: :m, **attributes)
    @size = size
    @attributes = attributes
  end

  def call
    tag.div(
      tag.img(
        **@attributes,
        class: "object-contain h-full w-full",
      ),
      class: "
        #{SIZES[@size]}
        rounded border border-gray-100
        bg-white overflow-hidden
        #{@attributes[:class]}
      "
    )
  end
end
