# frozen_string_literal: true

module SolidusAdmin
  # Renders the main navigation of Solidus Admin.
  class MainNavComponent < BaseComponent
    erb_template <<~ERB
      <nav>
        <%=
          render component("main_nav_item").with_collection(
            container.all("main_nav").sort_by(&:position)
          )
        %>
      </nav>
    ERB
  end
end
