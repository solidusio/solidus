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

  def name
    t(".main_nav.#{@item.key}")
  end

  def icon
    common_classes = "inline-block w-[1.125rem] h-[1.125rem] mr-[0.68rem] body-small"

    return tag.span(class: common_classes) unless @item.icon
    icon_tag(@item.icon, class: "#{common_classes} align-text-bottom fill-current", "aria-hidden" => true)
  end

  def path
    @item.path(@url_helpers)
  end

  def item_active_classes
    return unless active?

    "active"
  end

  def link_active_classes
    return unless active?

    "text-red-500 bg-gray-50"
  end

  def nested_nav_active_classes
    return if active?

    "hidden"
  end

  def link_level_classes
    if @item.top_level
      "body-small-bold text-black"
    else
      "body-small text-gray-600"
    end
  end

  def nested_items
    return unless @item.children?

    tag.ul(
      class: nested_nav_active_classes
    ) do
      render self.class.with_collection(@item.children, url_helpers: @url_helpers, fullpath: @fullpath)
    end
  end

  def active?
    @item.active?(@url_helpers, @fullpath)
  end
end
