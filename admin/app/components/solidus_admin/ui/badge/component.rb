# frozen_string_literal: true

class SolidusAdmin::UI::Badge::Component < SolidusAdmin::BaseComponent
  include ViewComponent::InlineTemplate

  COLORS = {
    graphite_light: "text-black bg-graphiteLight",
    red: 'text-red-500 bg-red-100',
    green: 'text-forest bg-seafoam',
    blue: 'text-blue bg-sky',
    black: 'text-white bg-black',
    yellow: 'text-orange bg-papayaWhip',
  }.freeze

  SIZES = {
    s: 'leading-[16px] px-[8px] py-[2px] text-[12px] font-[500]',
    m: 'leading-[20px] px-[12px] py-[2px] text-[14px] font-[500]',
    l: 'leading-[24px] px-[12px] py-[2px] text-[16px] font-[500]',
  }.freeze

  def initialize(name:, color: :graphite_light, size: :m)
    @name = name

    @class_name = [
      'inline-flex items-center rounded-full', # layout
      SIZES.fetch(size.to_sym), # size
      COLORS.fetch(color.to_sym), # color
    ].join(' ')
  end

  erb_template <<~ERB
    <div class="<%= @class_name %>"><%= @name %></div>
  ERB
end
