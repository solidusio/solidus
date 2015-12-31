class CreateSpreeOrdersPromotions < ActiveRecord::Migration
  def change
    create_table :solidus_orders_promotions, :id => false do |t|
      t.references :order
      t.references :promotion
    end
  end
end
