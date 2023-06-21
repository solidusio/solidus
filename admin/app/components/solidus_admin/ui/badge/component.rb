# frozen_string_literal: true

class SolidusAdmin::UI::Badge::Component < SolidusAdmin::BaseComponent
  COLORS = {
    graphite_light: "text-black bg-graphiteLight",
    red: 'text-red-500 bg-red-100',
    green: 'text-forest bg-seafoam',
    blue: 'text-blue bg-sky',
    black: 'text-white bg-black',
    yellow: 'text-yellow bg-[#feecd4]',
  }.freeze

  def initialize(name:, color: :graphite_light)
    @name = name

    @class_name = [
      'inline-flex items-center rounded-full', # layout
      'leading-[20px] px-[12px] py-[2px] text-[14px] font-[500]', # size
      COLORS.fetch(color.to_sym), # color
    ].join(' ')
  end

  erb_template <<~ERB
    <div class="<%= @class_name %>"><%= @name %></div>
  ERB
end
