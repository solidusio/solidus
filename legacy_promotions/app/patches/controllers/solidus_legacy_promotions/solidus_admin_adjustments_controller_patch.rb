# frozen_string_literal: true

module SolidusLegacyPromotions
  module SolidusAdminAdjustmentsControllerPatch
    private

    def load_adjustments
      @adjustments = @order
        .all_adjustments
        .eligible
        .order("adjustable_type ASC, created_at ASC")
        .ransack(params[:q])
        .result
    end

    if Object.const_defined?("SolidusAdmin::AdjustmentsController")
      SolidusAdmin::AdjustmentsController.prepend self
    end
  end
end
