# frozen_string_literal: true

# Menu item within a {Sidebar}
class SolidusAdmin::Sidebar::Item::Component < SolidusAdmin::BaseComponent
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
