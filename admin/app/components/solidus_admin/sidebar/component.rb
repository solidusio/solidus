# frozen_string_literal: true

# Renders the sidebar
class SolidusAdmin::Sidebar::Component < SolidusAdmin::BaseComponent
  def initialize(
    logo_path: SolidusAdmin::Config.logo_path,
    items: container["main_nav_items"],
    item_component: component("sidebar/item")
  )
    @logo_path = logo_path
    @items = items
    @item_component = item_component
  end

  erb_template <<~ERB
    <div>
      <%= image_tag @logo_path, alt: "Solidus" %>
      <nav data-controller="main-nav">
        <%= render @item_component.with_collection(items) %>
      </nav>
    </div>
  ERB

  def items
    @items.sort_by(&:position)
  end
end
