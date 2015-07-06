class SeedStoreCreditUpdateReasons < ActiveRecord::Migration
  def up
    Spree::StoreCreditUpdateReason.create!(name: 'Credit Given In Error')
  end

  def down
    # intentionally left blank
  end
end
