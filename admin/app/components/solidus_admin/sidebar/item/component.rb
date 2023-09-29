# frozen_string_literal: true

# Menu item within a {Sidebar}
class SolidusAdmin::Sidebar::Item::Component < SolidusAdmin::BaseComponent
  with_collection_parameter :item

  # @param item [SolidusAdmin::MainNavItem
  # @param fullpath [String] the current path
  # @param url_helpers [#solidus_admin, #spree] context for generating paths
  def initialize(
    item:,
    fullpath: "#",
    url_helpers: Struct.new(:spree, :solidus_admin).new(spree, solidus_admin)
  )
    @item = item
    @url_helpers = url_helpers
    @fullpath = fullpath
  end

  def path
    @item.path(@url_helpers)
  end

  def active?
    @item.active?(@url_helpers, @fullpath)
  end
end
