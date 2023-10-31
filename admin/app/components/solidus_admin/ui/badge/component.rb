# frozen_string_literal: true

class SolidusAdmin::UI::Badge::Component < SolidusAdmin::BaseComponent
  COLORS = {
    graphite_light: "text-black bg-graphite-light",
    red: 'text-red-500 bg-red-100',
    green: 'text-forest bg-seafoam',
    blue: 'text-blue bg-sky',
    black: 'text-white bg-black',
    yellow: 'text-orange bg-papaya-whip',
  }.freeze

  SIZES = {
    s: 'px-2 py-0.5 text-xs font-semibold',
    m: 'px-3 py-0.5 text-sm font-semibold',
    l: 'px-3 py-0.5 text-base font-semibold',
  }.freeze

  def initialize(name:, color: :graphite_light, size: :m)
    @name = name

    @class_name = [
      'inline-flex items-center rounded-full whitespace-nowrap', # layout
      SIZES.fetch(size.to_sym), # size
      COLORS.fetch(color.to_sym), # color
    ].join(' ')
  end

  erb_template <<~ERB
    <div class="<%= @class_name %>"><%= @name %></div>
  ERB
end
