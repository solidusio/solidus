# frozen_string_literal: true

module SolidusLegacyPromotions
  module SpreeOrderStateMachinePatch
    def define_state_machine!
      super
      state_machine do
        if states[:delivery]
          before_transition from: :delivery, do: :apply_shipping_promotions
        end
      end
    end

    Spree::Core::StateMachines::Order::ClassMethods.prepend self
  end
end
