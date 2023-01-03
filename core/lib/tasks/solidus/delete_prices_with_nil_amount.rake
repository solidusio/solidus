# frozen_string_literal: true

namespace :solidus do
  desc "Delete Spree::Price records (including discarded) which amount field is NULL"
  task delete_prices_with_nil_amount: :environment do
    Spree::Price.with_discarded.where(amount: nil).delete_all
  end
end

