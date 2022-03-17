# frozen_string_literal: true

class SetPromotionsWithAnyPolicyToAllIfPossible < ActiveRecord::Migration[5.2]
  def up
    Spree::Promotion.where(match_policy: :any).includes(:promotion_rules).all.each do |promotion|
      if promotion.promotion_rules.length <= 1
        promotion.update(match_policy: :all)
      end
    end
  end

  def down
    # No-Op
  end
end
