module Spree
  class Promotion
    module Rules
      class User < PromotionRule
        belongs_to :user, class_name: Solidus::UserClassHandle.new

        has_many :promotion_rule_users, class_name: 'Solidus::PromotionRuleUser',
                                        foreign_key: :promotion_rule_id
        has_many :users, through: :promotion_rule_users, class_name: Solidus::UserClassHandle.new

        def applicable?(promotable)
          promotable.is_a?(Solidus::Order)
        end

        def eligible?(order, options = {})
          users.include?(order.user)
        end

        def user_ids_string
          user_ids.join(',')
        end

        def user_ids_string=(s)
          self.user_ids = s.to_s.split(',').map(&:strip)
        end
      end
    end
  end
end
