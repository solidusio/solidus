# frozen_string_literal: true

module SolidusAdmin
  # Menu item within a {MainNavComponent}
  class MainNavItemComponent < BaseComponent
    with_collection_parameter :item

    attr_reader :item

    def initialize(item:)
      @item = item
      super
    end

    erb_template <<~ERB
      <a href="#">
        <%= item.title %>
      </a>
    ERB
  end
end
