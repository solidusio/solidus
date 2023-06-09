# frozen_string_literal: true

module SolidusAdmin
  # Renders the main navigation of Solidus Admin.
  class MainNav::Component < BaseComponent
    def initialize(items: container["main_nav_items"], item_component: component("main_nav_item"))
      @items = items
      @item_component = item_component
    end

    erb_template <<~ERB
      <nav>
        <%= render @item_component.with_collection(items) %>
      </nav>
    ERB

    def items
      @items.sort_by(&:position)
    end
  end
end
