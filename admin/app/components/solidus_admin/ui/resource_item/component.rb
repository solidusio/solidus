# frozen_string_literal: true

class SolidusAdmin::UI::ResourceItem::Component < SolidusAdmin::BaseComponent
  def initialize(title:, subtitle:, thumbnail: nil)
    @thumbnail = thumbnail
    @title = title
    @subtitle = subtitle
  end
end
