# frozen_string_literal: true

class SolidusAdmin::UI::Badge::Component < SolidusAdmin::BaseComponent
  STYLES = {
    graphite_light: "color-black bg-graphiteLight",
    red: 'color-red-500 bg-red-100',
    green: 'color-forest bg-seafoam',
    blue: 'color-blue bg-sky',
    black: 'color-white bg-black',
    yellow: 'color-yellow bg-[#feecd4]',
  }.freeze

  SIZES = {
    m: 'leading-[20px] px-[12px] py-[2px] text-[14px] font-[500]',
  }.freeze

  def initialize(name:, style: :graphite_light, size: :m)
    @name = name
    @style = style.to_sym
    @size = size.to_sym
  end

  erb_template <<~ERB
    <div class="
      inline-flex
      items-center
      rounded-full
      <%= SIZES.fetch(@size) %>
      <%= STYLES.fetch(@style) %>
    "><%= @name %></div>
  ERB
end
