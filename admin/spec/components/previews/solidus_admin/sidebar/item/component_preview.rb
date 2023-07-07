# frozen_string_literal: true

require "solidus_admin/main_nav_item"

# @component "sidebar/item"
class SolidusAdmin::Sidebar::Item::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  DUMMY_ROUTE = :foo_path

  DUMMY_PATH = "#"

  # @param active toggle { description: "Whether the item is active" }
  # @param key text { description: "ID also used for i18n" }
  # @param icon text { description: "RemixIcon name (https://remixicon.com/)" }
  def overview(active: false, key: "orders", icon: "inbox-line")
    item = SolidusAdmin::MainNavItem.new(
      key: key,
      icon: icon,
      position: 1,
      route: DUMMY_ROUTE
    )

    render_with_template(
      locals: {
        item: item,
        url_helpers: url_helpers,
        fullpath: fullpath(active)
      }
    )
  end

  private

  # solidus_admin.foo_path => "#"
  def url_helpers
    Struct.new(:solidus_admin).new(
      Struct.new(DUMMY_ROUTE).new(DUMMY_PATH)
    )
  end

  def fullpath(active)
    active ? DUMMY_PATH : ""
  end
end
