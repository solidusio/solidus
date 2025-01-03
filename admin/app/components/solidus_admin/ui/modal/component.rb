# frozen_string_literal: true

class SolidusAdmin::UI::Modal::Component < SolidusAdmin::BaseComponent
  renders_one :actions

  def initialize(title:, close_path: nil, closable: true, open: false, **attributes)
    @title = title
    @close_path = close_path
    @closable = closable
    @attributes = attributes
    @attributes[:open] = open
  end
end
