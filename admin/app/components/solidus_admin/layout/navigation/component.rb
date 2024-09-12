# frozen_string_literal: true

class SolidusAdmin::Layout::Navigation::Component < SolidusAdmin::BaseComponent
  def initialize(
    store:,
    logo_path: SolidusAdmin::Config.logo_path,
    items: SolidusAdmin::Config.menu_items
  )
    @logo_path = logo_path
    @items = items.map do |attrs|
      children = attrs[:children].to_a.map { SolidusAdmin::MenuItem.new(**_1, top_level: false) }
      SolidusAdmin::MenuItem.new(**attrs, children:, top_level: true)
    end
    @store = store
  end

  def before_render
    url = @store.url
    url = "https://#{url}" unless url.start_with?("http")
    @store_url = url
  end

  def items
    @items.sort_by(&:position)
  end
end
