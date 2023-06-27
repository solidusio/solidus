# frozen_string_literal: true

# Menu item within a {Sidebar}
class SolidusAdmin::Sidebar::Item::Component < SolidusAdmin::BaseComponent
  include ViewComponent::InlineTemplate

  with_collection_parameter :item

  def initialize(item:)
    @item = item
  end

  # Arbitrary Tailwind background images is not working:
  # https://github.com/tailwindlabs/tailwindcss/discussions/6617
  erb_template <<~ERB
    <div class="
        py-2 px-3 mb-1
        bg-no-repeat bg-left bg-origin-content
      " style="background-image: url('<%= image_path(@item.icon) %>')">
      <a href="#" class="
        pl-[1.81rem]
        text-sm text-black
        font-sans font-bold
      ">
        <%= name %>
      </a>
    </div>
  ERB

  def name
    t(".main_nav.#{@item.key}")
  end
end
