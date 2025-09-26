# frozen_string_literal: true

class SolidusAdmin::Layout::Flashes::Alerts::Component < SolidusAdmin::BaseComponent
  attr_reader :alerts

  # Construct alert flashes like:
  #   flash[:alert] = { <alert_type>: { title: "", message: "" } }
  # See +SolidusAdmin::UI::Alert::Component::SCHEMES+ for available alert types.
  #
  # If a string is passed to flash[:alert], we treat it is a body of the alert message and fall back to +danger+ type
  # and default title (see +SolidusAdmin::UI::Alert::Component+).
  def initialize(alerts:)
    if alerts.is_a?(String)
      alerts = {danger: {message: alerts}}
    end

    @alerts = alerts.slice(*SolidusAdmin::UI::Alert::Component::SCHEMES.keys)
  end
end
