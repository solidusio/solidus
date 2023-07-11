# frozen_string_literal: true

# Renders the sidebar
class SolidusAdmin::Sidebar::Component < SolidusAdmin::BaseComponent
  def initialize(
    store:,
    logo_path: SolidusAdmin::Config.logo_path,
    items: container["main_nav_items"],
    item_component: component("sidebar/item"),
    account_nav_component: component("sidebar/account_nav")
  )
    @logo_path = logo_path
    @items = items
    @item_component = item_component
    @account_nav_component = account_nav_component
    @store = store
  end

  def items
    @items.sort_by(&:position)
  end
end
