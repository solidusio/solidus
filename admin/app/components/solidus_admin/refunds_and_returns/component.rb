# frozen_string_literal: true

class SolidusAdmin::RefundsAndReturns::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers
  renders_one :actions

  def initialize(current_class:)
    @current_class = current_class
  end

  def tabs
    {}
  end
end
