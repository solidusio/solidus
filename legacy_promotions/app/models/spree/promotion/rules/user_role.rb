# frozen_string_literal: true

module Spree
  class Promotion < Spree::Base
    module Rules
      class UserRole < PromotionRule
        preference :role_ids, :array, default: []

        MATCH_POLICIES = %w(any all)
        preference :match_policy, default: MATCH_POLICIES.first

        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, _options = {})
          return false unless order.user
          if all_match_policy?
            match_all_roles?(order)
          else
            match_any_roles?(order)
          end
        end

        private

        def all_match_policy?
          preferred_match_policy == 'all' && preferred_role_ids.present?
        end

        def user_roles(order)
          order.user.spree_roles.where(id: preferred_role_ids)
        end

        def match_all_roles?(order)
          user_roles(order).count == preferred_role_ids.count
        end

        def match_any_roles?(order)
          user_roles(order).exists?
        end
      end
    end
  end
end
