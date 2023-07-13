# frozen_string_literal: true

class SolidusAdmin::UI::Toast::Component < SolidusAdmin::BaseComponent
  SCHEMES = {
    default: %w[
      bg-gray-800 text-white
    ],
    error: %w[
      bg-red-500 text-white
    ],
  }

  def initialize(text:, icon: nil, scheme: :default)
    @text = text
    @icon = icon
    @scheme = scheme.to_sym
  end

  def icon_tag(icon, class_names: nil)
    href = image_path("solidus_admin/remixicon.symbol.svg") + "#ri-#{icon}"
    tag.svg(
      class: "w-[1.125rem] h-[1.125rem] fill-current #{class_names}",
    ) do
      tag.use(
        "xlink:href": href
      )
    end
  end
end
