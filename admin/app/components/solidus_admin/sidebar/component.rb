# frozen_string_literal: true

module SolidusAdmin
  # Renders the sidebar
  class Sidebar::Component < BaseComponent
    def initialize(
      solidus_logo_component: component('solidus_logo'),
      main_nav_component: component('main_nav')
    )
      @solidus_logo_component = solidus_logo_component
      @main_nav_component = main_nav_component
    end

    erb_template <<~ERB
      <aside class="
        col-start-1 col-end-2
        lg:col-start-1 lg:col-end-3
        bg-gray-100
        h-screen
      ">
        <%= render @solidus_logo_component.new %>
        <%= render @main_nav_component.new %>
      </aside>
    ERB
  end
end
