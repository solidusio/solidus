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
    <aside class="
      border-r border-r-gray-100
      col-start-1 col-end-2
      lg:col-start-1 lg:col-end-3
      h-screen
      p-[16px]
    ">
      <%= image_tag @logo_path, alt: "Solidus" %>
      <nav data-controller="main-nav">
        <%= render @item_component.with_collection(items) %>
      </nav>
    </aside>
  ERB

  def items
    @items.sort_by(&:position)
  end
end
