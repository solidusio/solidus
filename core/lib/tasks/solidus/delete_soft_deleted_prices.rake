# frozen_string_literal: true

namespace :solidus do
  desc <<~DESC
    Permanently deletes Spree::Price records that have been soft-deleted
    (deleted_at IS NOT NULL). Run this before upgrading to Solidus 5.0,
    which removes the deleted_at column from spree_prices entirely.
  DESC

  task delete_soft_deleted_prices: :environment do
    scope = Spree::Price.unscoped.where.not(deleted_at: nil)
    count = scope.count

    if count.zero?
      puts "No soft-deleted prices found. Nothing to do."
    else
      puts "Found #{count} soft-deleted price(s). Deleting permanently..."
      scope.delete_all
      puts "Done."
    end
  end
end
