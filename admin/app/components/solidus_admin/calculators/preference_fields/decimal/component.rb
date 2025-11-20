# frozen_string_literal: true

class SolidusAdmin::Calculators::PreferenceFields::Decimal::Component < SolidusAdmin::BaseComponent
  def initialize(form:, attribute:, label:)
    @form = form
    @attribute = attribute
    @label = label
  end
end
