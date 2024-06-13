# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Adjustments::Index::Adjustment::Component < SolidusAdmin::BaseComponent
  attr_reader :adjustment, :source, :model_name

  def initialize(adjustment)
    @adjustment = adjustment
    @source = adjustment.source
    @model_name = source&.model_name&.human
  end

  def detail
  end
end
