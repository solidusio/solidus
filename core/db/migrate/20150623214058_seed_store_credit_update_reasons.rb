class SeedStoreCreditUpdateReasons < ActiveRecord::Migration
  def up
    Solidus::StoreCreditUpdateReason.create!(name: 'Credit Given In Error')
  end

  def down
    Solidus::StoreCreditUpdateReason.find_by(name: 'Credit Given In Error').try!(:destroy)
  end
end
