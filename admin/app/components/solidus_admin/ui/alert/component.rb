# frozen_string_literal: true

class SolidusAdmin::UI::Alert::Component < SolidusAdmin::BaseComponent
  ANIMATION_CSS_CLASSES = ["-translate-y-[150%]", "opacity-0"]

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

  def initialize(title:, message:, dismissable: true, scheme: :success)
    @title = title
    @message = message
    @dismissable = dismissable
    @scheme = scheme
  end

  def before_render
    @title = @title.presence || t(".defaults.titles")[@scheme.to_sym]
  end

  def icon
    icon_tag(ICONS.dig(@scheme.to_sym, :name), class: "w-5 h-5 #{ICONS.dig(@scheme.to_sym, :class)}")
  end

  def container_classes
    classes = ["flex", "w-full", "justify-between", "min-h-[85px]", "rounded-lg", "p-4", "border", "pointer-events-auto"]

    if @dismissable
      classes += ANIMATION_CSS_CLASSES
      classes += ["transform", "duration-500"]
    end

    classes += SCHEMES.fetch(@scheme.to_sym)

    classes.join(" ")
  end

  def stimulus_attributes
    return {} unless @dimissable

    {
      "data-controller": "alert-animation",
      "data-alert-animation-animation-class": ANIMATION_CSS_CLASSES.join(" "),
      "data-alert-animation-transition-value": Rails.env.test? ? 1000 : 500
    }
  end
end
