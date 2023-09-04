# frozen_string_literal: true

# Renders the sidebar
class SolidusAdmin::Sidebar::Component < SolidusAdmin::BaseComponent
  def initialize(
    store:,
    logo_path: SolidusAdmin::Config.logo_path,
    items: SolidusAdmin::Config.menu_items,
    icon_component: component("ui/icon"),
    item_component: component("sidebar/item"),
    account_nav_component: component("sidebar/account_nav"),
    switch_component: component("ui/forms/switch")
  )
    @logo_path = logo_path
    @items = items.map do |attrs|
      children = attrs[:children].to_a.map { SolidusAdmin::MainNavItem.new(**_1, top_level: false) }
      SolidusAdmin::MainNavItem.new(**attrs, children: children, top_level: true)
    end
    @store = store

    @icon_component = icon_component
    @item_component = item_component
    @account_nav_component = account_nav_component
    @switch_component = switch_component
  end

  def items
    @items.sort_by(&:position)
  end
end
