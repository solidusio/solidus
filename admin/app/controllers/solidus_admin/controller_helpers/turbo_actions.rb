# frozen_string_literal: true

module SolidusAdmin::ControllerHelpers::TurboActions
  extend ActiveSupport::Concern

  included do
    class_attribute :registered_turbo_actions, instance_writer: false, default: []
    before_action :ensure_turbo_frame_request, if: ->(controller) do
      registered_turbo_actions.include?(controller.action_name.to_sym)
    end
  end

  class_methods do
    def turbo_actions(*actions)
      self.registered_turbo_actions += actions.map(&:to_sym)
    end
  end

  private

  def ensure_turbo_frame_request
    redirect_to action: :index unless turbo_frame_request?
  end
end
