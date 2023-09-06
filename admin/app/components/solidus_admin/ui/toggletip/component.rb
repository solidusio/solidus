# frozen_string_literal: true

class SolidusAdmin::UI::Toggletip::Component < SolidusAdmin::BaseComponent
  # Icon size: 1rem
  # Arrow size: 0.375rem
  # Banner padding x: 0.75rem
  POSITIONS = {
    up: {
      arrow: %w[before:top-0 before:left-1/2 before:translate-y-[-50%] before:translate-x-[-50%]],
      bubble: %w[translate-x-[calc(-50%+(1rem/2))] translate-y-[calc(0.375rem/2)]]
    },
    up_right: {
      arrow: %w[before:top-0 before:right-0 before:translate-y-[-50%]],
      bubble: %w[translate-x-[calc(-100%+0.75rem+(1rem/2)+(0.375rem/2))] translate-y-[calc(0.375rem/2)]]
    },
    right: {
      arrow: %w[before:top-1/2 before:right-0 before:translate-y-[-50%] before:translate-x-[0.93rem]],
      bubble: %w[translate-x-[calc(-100%+(-0.375rem/2))] translate-y-[calc(-50%-(1rem/2))]]
    },
    down_right: {
      arrow: %w[before:bottom-0 before:right-0 before:translate-y-[50%]],
      bubble: %w[translate-x-[calc(-100%+0.75rem+(1rem/2)+(0.376rem/2))] translate-y-[calc(-100%-1rem-(0.375rem/2))]]
    },
    down: {
      arrow: %w[before:bottom-0 before:left-1/2 before:translate-y-[50%] before:translate-x-[-50%]],
      bubble: %w[translate-x-[calc(-50%+(1rem/2))] translate-y-[calc(-100%-1rem-(0.375rem/2))]]
    },
    down_left: {
      arrow: %w[before:bottom-0 before:left-0 before:translate-y-[50%]],
      bubble: %w[translate-x-[calc(-1rem/2)] translate-y-[calc(-100%-0.75rem-0.375rem)]]
    },
    left: {
      arrow: %w[before:top-1/2 before:left-0 before:translate-y-[-50%] before:translate-x-[-0.93rem]],
      bubble: %w[translate-x-[calc(1rem+(0.375rem/2))] translate-y-[calc(-50%-(1rem/2))]]
    },
    up_left: {
      arrow: %w[before:top-0 before:left-0 before:translate-y-[-50%]],
      bubble: %w[translate-x-[calc(-0.75rem+0.375rem)] translate-y-[calc(0.375rem/2)]]
    },
    none: {
      arrow: %w[before:hidden],
      bubble: %w[translate-x-[calc(-50%+0.75rem)]]
    }
  }.freeze

  THEMES = {
    light: {
      icon: %w[fill-gray-500],
      bubble: %w[text-gray-800 bg-gray-50]
    },
    dark: {
      icon: %w[fill-gray-800],
      bubble: %w[text-white bg-gray-800]
    }
  }.freeze

  # @param text [String] The toggletip text
  # @param position [Symbol] The position of the arrow in relation to the
  #   toggletip. The latter will be positioned accordingly in relation to the
  #   help icon. Defaults to `:up`. See `POSITIONS` for available options.
  # @param theme [Symbol] The theme of the toggletip. Defaults to `:light`. See
  #   `THEMES` for available options.
  def initialize(text:, position: :down, theme: :light, **attributes)
    @text = text || guide
    @position = position
    @theme = theme
    @attributes = attributes
    @attributes[:class] = [
      "relative inline-block",
      @attributes[:class],
    ].join(" ")
  end

  def icon_theme_classes
    THEMES.fetch(@theme)[:icon].join(" ")
  end

  def bubble_theme_classes
    THEMES.fetch(@theme)[:bubble].join(" ")
  end

  def bubble_position_classes
    POSITIONS.fetch(@position)[:bubble].join(" ")
  end

  def bubble_arrow_pseudo_element
    (
      [
        "before:content['']",
        "before:absolute",
        "before:w-[0.375rem]",
        "before:h-[0.375rem]",
        "before:rotate-45",
        "before:bg-inherit",
      ] + POSITIONS.fetch(@position)[:arrow]
    ).join(" ")
  end
end
