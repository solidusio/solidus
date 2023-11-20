# frozen_string_literal: true

class SolidusAdmin::UI::Thumbnail::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: 'h-6 w-6',
    m: 'h-10 w-10',
    l: 'h-20 w-20',
  }.freeze

  def initialize(icon: nil, size: :m, **attributes)
    @icon = icon
    @size = size
    @attributes = attributes
  end

  def call
    icon = if @icon
      icon_tag(@icon, class: "bg-gray-25 fill-gray-700 #{SIZES[@size]} p-2")
    else
      tag.img(**@attributes, class: "object-contain #{SIZES[@size]}")
    end

    tag.div(icon, class: "
      #{SIZES[@size]}
      rounded border border-gray-100
      bg-white overflow-hidden
      content-box
      #{@attributes[:class]}
    ")
  end
end
