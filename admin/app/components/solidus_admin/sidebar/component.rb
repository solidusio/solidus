# frozen_string_literal: true

# Renders the sidebar
class SolidusAdmin::Sidebar::Component < SolidusAdmin::BaseComponent
  def initialize(
    store:,
    logo_path: SolidusAdmin::Config.logo_path,
    items: container["main_nav_items"],
    item_component: component("sidebar/item")
  )
    @logo_path = logo_path
    @items = items
    @item_component = item_component
    @store = store
  end

  erb_template <<~ERB
    <aside class="
      border-r border-r-gray-100
      col-start-1 col-end-2
      lg:col-start-1 lg:col-end-3
      bg-white
      h-screen
      p-[16px]
    ">
      <%= image_tag @logo_path, alt: "Solidus" %>
      <%= link_to @store.url,
            class: "
              block
              mt-4 px-2 py-1.5
              border border-gray-100 rounded-sm shadow-sm
              bg-arrow-right-up-line bg-right-top bg-no-repeat bg-origin-content
            " do %>
        <p class="
          text-sm text-black
          font-sans font-bold
        ">
          <%= @store.name %>
        </p>
        <p class="
          text-tiny text-gray-500
          font-sans
        ">
          <%= @store.url %>
        </p>
      <% end %>
      <nav data-controller="main-nav">
        <%= render @item_component.with_collection(items) %>
      </nav>
    </aside>
  ERB

  def items
    @items.sort_by(&:position)
  end
end
