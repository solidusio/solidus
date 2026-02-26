# frozen_string_literal: true

class SolidusAdmin::UI::Alert::Component < SolidusAdmin::BaseComponent
  SCHEMES = {
    success: %w[
      border-forest bg-seafoam
    ],
    warning: %w[
      border-orange bg-sazerac
    ],
    danger: %w[
      border-red-500 bg-red-100 text-black
    ],
    info: %w[
      border-gray-500 bg-gray-50
    ]
  }

  ICONS = {
    success: {
      name: "checkbox-circle-fill",
      class: "fill-forest"
    },
    warning: {
      name: "error-warning-fill",
      class: "fill-orange"
    },
    danger: {
      name: "error-warning-fill",
      class: "fill-red-500"
    },
    info: {
      name: "information-fill",
      class: "fill-gray-500"
    }
  }

  def initialize(title:, message:, scheme: :success)
    @title = title
    @message = message
    @scheme = scheme
  end

  def before_render
    @title = @title.presence || t(".defaults.titles")[@scheme.to_sym]
  end

  def icon
    icon_tag(ICONS.dig(@scheme.to_sym, :name), class: "w-5 h-5 #{ICONS.dig(@scheme.to_sym, :class)}")
  end
end
