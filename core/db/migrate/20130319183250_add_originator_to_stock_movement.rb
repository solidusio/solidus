class AddOriginatorToStockMovement < ActiveRecord::Migration
  def change
    change_table :solidus_stock_movements do |t|
      t.references :originator, polymorphic: true
    end
  end
end
