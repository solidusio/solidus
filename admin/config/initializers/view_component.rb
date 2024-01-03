# frozen_string_literal: true

Rails.application.config.view_component.capture_compatibility_patch_enabled = true

if Rails.env.development? || Rails.env.test?
  Rails.application.config.view_component.instrumentation_enabled = true
  Rails.application.config.view_component.use_deprecated_instrumentation_name = false

  bold  = "\e[1m"
  clear = "\e[0m"

  ActiveSupport::Notifications.subscribe("render.view_component") do |*args|
    next unless args.last[:name]&.starts_with?("SolidusAdmin::")

    event = ActiveSupport::Notifications::Event.new(*args)
    SolidusAdmin::BaseComponent.logger.debug \
      "  Rendered #{bold}#{event.payload[:name]}#{clear}" \
      " (Duration: #{event.duration.round(1)}ms)"
  end
end
