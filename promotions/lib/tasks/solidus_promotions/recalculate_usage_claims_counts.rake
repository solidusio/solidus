# frozen_string_literal: true

namespace :solidus_promotions do
  desc "Recalculate the usage claims counts of usage limited promotions and their codes"
  task recalculate_usage_claims_counts: :environment do
    SolidusPromotions::Promotion
      .with_discarded
      .where.not(usage_limit: nil)
      .or(SolidusPromotions::Promotion.with_discarded.where.not(per_code_usage_limit: nil))
      .find_each(&:recalculate_usage_claims_counts)
  end
end
