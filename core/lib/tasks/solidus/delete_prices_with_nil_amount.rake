# frozen_string_literal: true

namespace :solidus do
  desc "Delete Spree::Price records which amount field is NULL"
  task delete_prices_with_nil_amount: :environment do
    Spree::Price.where(amount: nil).delete_all
  end
end
