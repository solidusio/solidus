module Spree
  class Promotion
    module Rules
      class UserRole < PromotionRule
        preference :role_ids, :array, default: []

        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, options = {})
          order.user.spree_roles.exists?(id: preferred_role_ids) if order.user
        end
      end
    end
  end
end
