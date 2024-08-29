# frozen_string_literal: true

class SolidusAdmin::UI::Toggletip::Component < SolidusAdmin::BaseComponent
  POSITIONS = {
    below: {
      arrow: "before:top-0 before:left-1/2 before:translate-y-[-50%] before:translate-x-[-50%]",
      bubble: "translate-x-[calc(-50%+(1rem/2))] translate-y-[calc(0.375rem/2)]"
    },
    above: {
      arrow: "before:bottom-0 before:left-1/2 before:translate-y-[50%] before:translate-x-[-50%]",
      bubble: "translate-x-[calc(-50%+(1rem/2))] translate-y-[calc(-100%-1rem-(0.375rem/2))]"
    }
  }.freeze

  def initialize(text:, position: :above, **attributes)
    @text = text
    @position = position
    @attributes = attributes
    @attributes[:class] = "relative inline-block #{@attributes[:class]}"
  end
end
