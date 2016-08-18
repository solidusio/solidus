class CreateUnitCancels < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_unit_cancels do |t|
      t.references :inventory_unit, index: true, null: false
      t.string :reason
      t.string :created_by
      t.timestamps null: true
    end
  end
end
