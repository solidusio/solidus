# frozen_string_literal: true

# Reserve :alert for messages that should go in UI alert component. Everything else will be shown in UI toast.
module SolidusAdmin
  module FlashHelper
    def toasts
      flash.to_hash.with_indifferent_access.except(:alert)
    end

    def alerts
      flash.to_hash.with_indifferent_access.fetch(:alert, {})
    end
  end
end
