# frozen_string_literal: true

class SolidusAdmin::UI::Toast::Component < SolidusAdmin::BaseComponent
  SCHEMES = {
    default: %w[
      bg-full-black text-white
    ],
    error: %w[
      bg-red-500 text-white
    ]
  }

  def initialize(text:, icon: nil, scheme: :default)
    @text = text
    @icon = icon
    @scheme = scheme
  end
end
