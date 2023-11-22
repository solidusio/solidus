# frozen_string_literal: true

class SolidusAdmin::UI::Dropdown::Component < SolidusAdmin::BaseComponent
  DIRECTIONS = {
    left: "right-0",
    right: "left-0",
  }

  SIZES = {
    s: "w-5 h-5",
    m: "w-[22px] h-[22px]",
  }

  def initialize(text: nil, size: :m, direction: :left, **attributes)
    @text = text
    @size = size
    @attributes = attributes
    @direction = direction

    @attributes[:"data-controller"] = "#{stimulus_id} #{attributes[:"data-controller"]}"
    @attributes[:"data-action"] = "turbo:before-cache@window->#{stimulus_id}#close #{attributes[:"data-action"]}"
    @attributes[:class] = "
      #{@size == :m ? 'body-text' : 'body-small'}
      #{@attributes[:class]}
    "
  end
end
