# frozen_string_literal: true

# Menu item within a {Sidebar}
class SolidusAdmin::Sidebar::Item::Component < SolidusAdmin::BaseComponent
  with_collection_parameter :item

  def initialize(item:, url_helpers: solidus_admin_with_fallbacks)
    @item = item
    @url_helpers = url_helpers
  end

  def name
    t(".main_nav.#{@item.key}")
  end

  def icon
    common_classes = "inline-block w-[1.125rem] h-[1.125rem] mr-[0.68rem] text-sm"

    if @item.icon
      url = image_path(@item.icon)
      tag.span(
        "&nbsp;",
        class: "#{common_classes} align-text-bottom bg-black group-hover:bg-red-500",
        style: <<~CSS,
          mask: url(#{url}) 100% 100% no-repeat;
          -webkit-mask: url(#{url}) 100% 100% no-repeat;
        CSS
      )
    else
      tag.span(
        class: common_classes
      )
    end
  end

  def path
    @item.path(@url_helpers)
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

    tag.nav do
      render self.class.with_collection(@item.children, url_helpers: @url_helpers)
    end
  end
end
