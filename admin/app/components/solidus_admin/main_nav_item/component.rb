# frozen_string_literal: true

module SolidusAdmin
  # Menu item within a {MainNavComponent}
  class MainNavItem::Component < BaseComponent
    with_collection_parameter :item

    def initialize(item:)
      @item = item
    end

    erb_template <<~ERB
      <a href="#">
        <%= @item.title %>
      </a>
    ERB
  end
end
