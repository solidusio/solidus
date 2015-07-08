class SeedStoreCreditUpdateReasons < ActiveRecord::Migration
  def up
    Spree::StoreCreditUpdateReason.create!(name: 'Credit Given In Error')
  end

  def down
    Spree::StoreCreditUpdateReason.find_by(name: 'Credit Given In Error').try!(:destroy)
  end
end
