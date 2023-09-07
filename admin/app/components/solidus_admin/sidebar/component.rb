# frozen_string_literal: true

# Renders the sidebar
class SolidusAdmin::Sidebar::Component < SolidusAdmin::BaseComponent
  def initialize(
    store:,
    logo_path: SolidusAdmin::Config.logo_path,
    items: SolidusAdmin::Config.menu_items
  )
    @logo_path = logo_path
    @items = items.map do |attrs|
      children = attrs[:children].to_a.map { SolidusAdmin::MainNavItem.new(**_1, top_level: false) }
      SolidusAdmin::MainNavItem.new(**attrs, children: children, top_level: true)
    end
    @store = store
  end

  def items
    @items.sort_by(&:position)
  end
end
