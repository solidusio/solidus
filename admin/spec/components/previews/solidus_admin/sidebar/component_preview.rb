# frozen_string_literal: true

require "solidus_admin/main_nav_item"

# @component "sidebar"
class SolidusAdmin::Sidebar::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  class ItemComponent < SolidusAdmin::Sidebar::Item::Component
    def path
      "#"
    end

    def active?
      false
    end
  end

  # The item component is used to render main navigation items, which are
  # rendered within the sidebar.
  #
  # It needs to be passed a {SolidusAdmin::MainNavItem} instance, which
  # represents the data for a main navigation item.
  #
  # ```ruby
  # item = SolidusAdmin::MainNavItem.new(
  #   key: :overview,
  #   position: 80
  # )
  # render component("sidebar/item", item: item)
  # ```
  #
  # @param store_name text
  # @param store_url url
  # @param logo_path text { description: "Asset path to the store logo" }
  def overview(store_name: "Solidus store", store_url: "https://example.com", logo_path: SolidusAdmin::Config.logo_path)
    store = Struct.new(:name, :url).new(store_name, store_url)

    render_with_template(
      locals: {
        logo_path: logo_path,
        store: store,
        item_component: ItemComponent
      }
    )
  end
end
