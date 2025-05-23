# frozen_string_literal: true

class SolidusAdmin::Layout::Flashes::Alerts::Component < SolidusAdmin::BaseComponent
  attr_reader :alerts

  def initialize(alerts:)
    @alerts = alerts
  end
end
