# frozen_string_literal: true

# Menu item within a {Sidebar}
class SolidusAdmin::Layout::Navigation::Item::Component < SolidusAdmin::BaseComponent
  with_collection_parameter :item

  # @param item [SolidusAdmin::MenuItem]
  # @param fullpath [String] the current path
  def initialize(
    item:,
    fullpath: "#"
  )
    @item = item
    @fullpath = fullpath
  end

  def path
    @item.path(self)
  end

  def active?
    @item.active?(self, @fullpath)
  end
end
