class AddLaneToSolidusFriendlyPromotionsPromotions < ActiveRecord::Migration[7.0]
  def change
    add_column :friendly_promotions, :lane, :integer, null: false, default: 1
  end
end
