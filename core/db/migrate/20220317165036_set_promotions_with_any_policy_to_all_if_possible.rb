# frozen_string_literal: true

require "spree/migration"

class SetPromotionsWithAnyPolicyToAllIfPossible < Spree::Migration
  def up
    Spree::Promotion.where(match_policy: :any).includes(:promotion_rules).all.each do |promotion|
      if promotion.promotion_rules.length <= 1
        promotion.update!(match_policy: :all)
      else
        raise StandardError, <<~MSG
          You have promotions with a match policy of any and more than one rule. Please
          run `bundle exec rake solidus:split_promotions_with_any_match_policy`.
        MSG
      end
    end
  end

  def down
    # No-Op
  end
end
