# frozen_string_literal: true

class SolidusAdmin::Layout::Flashes::Toasts::Component < SolidusAdmin::BaseComponent
  attr_reader :toasts

  def initialize(toasts:)
    @toasts = toasts
  end
end
