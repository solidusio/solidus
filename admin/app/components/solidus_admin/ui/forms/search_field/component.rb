# frozen_string_literal: true

class SolidusAdmin::UI::Forms::SearchField::Component < SolidusAdmin::BaseComponent
  def initialize(**attributes)
    @attributes = attributes
    @attributes[:type] ||= :search
    @attributes[:class] = "search-cancel:appearance-none peer !px-10 #{@attributes[:class]}"
    @attributes[:"data-#{stimulus_id}-target"] = "input"
  end
end
