# frozen_string_literal: true

class SolidusAdmin::Calculators::Form::Component < SolidusAdmin::BaseComponent
  def initialize(form:, calculators:)
    @form = form
    @calculators = calculators
  end
end
