class CreateAdjustmentReason < ActiveRecord::Migration
  def change
    create_table :solidus_adjustment_reasons do |t|
      t.string   "name"
      t.string   "code"
      t.boolean  "active",     default: true

      t.timestamps null: true
    end

    add_index :solidus_adjustment_reasons, :code
    add_index :solidus_adjustment_reasons, :active

    change_table :solidus_adjustments do |t|
      t.references :adjustment_reason
    end
  end
end
