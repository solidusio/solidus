class CreateAdjustmentReason < ActiveRecord::Migration
  def change
    create_table :spree_adjustment_reasons do |t|
      t.string   "name"
      t.string   "code"
      t.boolean  "active", default: true

      t.timestamps null: true
    end

    add_index :spree_adjustment_reasons, :code
    add_index :spree_adjustment_reasons, :active

    change_table :spree_adjustments do |t|
      t.references :adjustment_reason
    end
  end
end
