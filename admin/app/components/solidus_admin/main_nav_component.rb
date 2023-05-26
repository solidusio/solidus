# frozen_string_literal: true

module SolidusAdmin
  # Renders the main navigation of Solidus Admin.
  class MainNavComponent < BaseComponent
    def initialize(main_nav_item_component: component("main_nav_item"), items: container.within_namespace("main_nav"))
      @main_nav_item_component = main_nav_item_component
      @items = items
      super
    end

    erb_template <<~ERB
      <nav>
        <%=
          render @main_nav_item_component.with_collection(
            sorted_items
          )
        %>
      </nav>
    ERB

    private

    def sorted_items
      @items.sort_by(&:position)
    end
  end
end
