# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Adjustments::Index::Source::Component < SolidusAdmin::BaseComponent
  attr_reader :adjustment, :source, :model_name

  def initialize(adjustment)
    @adjustment = adjustment
    @source = adjustment.source
    @model_name = source&.model_name&.human
  end

  def call
    render component("ui/thumbnail_with_caption").new(icon: icon, caption: caption, detail: detail)
  end

  def caption
    adjustment.label
  end

  def detail
  end

  def icon
    "question-line"
  end
end
