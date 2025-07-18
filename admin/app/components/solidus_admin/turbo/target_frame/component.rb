# frozen_string_literal: true

class SolidusAdmin::Turbo::TargetFrame::Component < SolidusAdmin::BaseComponent
  def initialize(id, source: nil)
    @id = id
    @source = source
  end
end
