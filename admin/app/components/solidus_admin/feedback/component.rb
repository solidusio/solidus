# frozen_string_literal: true

class SolidusAdmin::Feedback::Component < SolidusAdmin::BaseComponent
  # @param button_component [Class] The button component class (default: component("ui/button")).
  def initialize(button_component: component("ui/button"))
    @button_component = button_component
  end
end
