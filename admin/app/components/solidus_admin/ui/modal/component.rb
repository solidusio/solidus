# frozen_string_literal: true

class SolidusAdmin::UI::Modal::Component < SolidusAdmin::BaseComponent
  renders_one :actions

  def initialize(title:, close_path: nil, open: true, **attributes)
    @title = title
    @close_path = close_path
    @attributes = attributes
    @attributes.merge! stimulus_value(name: "open-on-connect", value: open)
  end
end
