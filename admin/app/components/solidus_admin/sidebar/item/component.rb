# frozen_string_literal: true

# Menu item within a {Sidebar}
class SolidusAdmin::Sidebar::Item::Component < SolidusAdmin::BaseComponent
  with_collection_parameter :item

  def initialize(
    item:,
    url_helpers: Struct.new(:spree, :solidus_admin).new(spree, solidus_admin)
  )
    @item = item
    @url_helpers = url_helpers
  end

  def name
    t(".main_nav.#{@item.key}")
  end

  def icon
    common_classes = "inline-block w-[1.125rem] h-[1.125rem] mr-[0.68rem] text-sm"

    return tag.span(class: common_classes) unless @item.icon

    href = image_path("solidus_admin/remixicon.symbol.svg") + "#ri-#{@item.icon}"
    tag.svg(
      class: "#{common_classes} align-text-bottom fill-black group-hover:fill-red-500 group-[.active]:fill-red-500"
    ) do
      tag.use(
        "xlink:href": href
      )
    end
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
      "text-black font-bold"
    else
      "text-gray-600"
    end
  end

  def nested_items
    return unless @item.children?

    tag.nav(
      class: nested_nav_active_classes
    ) do
      render self.class.with_collection(@item.children, url_helpers: @url_helpers)
    end
  end

  def active?
    @item.active?(@url_helpers, request.fullpath)
  end
end
