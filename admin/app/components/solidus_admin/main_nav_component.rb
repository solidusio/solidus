# frozen_string_literal: true

module SolidusAdmin
  # Renders the main navigation of Solidus Admin.
  class MainNavComponent < BaseComponent
    include Import[
      "main_nav_item_component",
      items: "main_nav_items"
    ]

    erb_template <<~ERB
      <nav>
        <%=
          render main_nav_item_component.with_collection(
            sorted_items
          )
        %>
      </nav>
    ERB

    private

    def sorted_items
      items.sort_by(&:position)
    end
  end
end
