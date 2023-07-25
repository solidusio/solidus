# frozen_string_literal: true

class SolidusAdmin::UI::Icon::Component < SolidusAdmin::BaseComponent
  NAMES = Set.new(File.read("#{__dir__}/names.txt").split("\n").map(&:freeze)).freeze

  # Renders a remixincon svg.
  #
  # @param name [String] the name of the icon
  # @option attrs [String] :class the class to add to the svg
  # @see https://remixicon.com/
  def initialize(name:, **attrs)
    raise ArgumentError, "unkown icon #{name.inspect}" unless NAMES.include?(name.to_s)

    @name = name
    @attrs = attrs

    # Hide the icon from screen readers by default.
    @attrs['aria-hidden'] = true unless @attrs.key?('aria-hidden')
  end

  def call
    href = "#{image_path('solidus_admin/remixicon.symbol.svg')}#ri-#{@name}"
    content_tag(:svg, content_tag(:use, nil, "xlink:href": href), **@attrs)
  end
end
