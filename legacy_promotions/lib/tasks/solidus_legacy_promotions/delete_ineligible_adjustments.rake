# frozen_string_literal: true

namespace :solidus_legacy_promotions do
  desc "Delete ineligible adjustments"
  task delete_ineligible_adjustments: :environment do
    Spree::Adjustment.where(eligible: false).delete_all
  end
end
