# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Adjustments::Index::Adjustable::Component < SolidusAdmin::BaseComponent
  attr_reader :adjustment, :adjustable, :model_name

  def initialize(adjustment)
    @adjustment = adjustment
    @adjustable = adjustment.adjustable
    @model_name = adjustable&.model_name&.human
  end

  def call
    render component("ui/thumbnail_with_caption").new(caption: caption, detail: detail) do
      thumbnail
    end
  end

  def thumbnail
    render(component("ui/thumbnail").for(adjustment.adjustable, class: "basis-10"))
  end

  def caption
  end

  def detail
  end
end
