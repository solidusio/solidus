# frozen_string_literal: true

# Menu item within a {Sidebar}
class SolidusAdmin::Sidebar::Item::Component < SolidusAdmin::BaseComponent
  with_collection_parameter :item

  def initialize(item:)
    @item = item
  end

  def name
    t(".main_nav.#{@item.key}")
  end

  # Arbitrary Tailwind background images is not working:
  # https://github.com/tailwindlabs/tailwindcss/discussions/6617
  def background_image_style_attribute
    return unless @item.icon

    "style=\"background-image: url('".html_safe +
      image_path(@item.icon) +
      "')\"".html_safe
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
      render self.class.with_collection(@item.children)
    end
  end
end
