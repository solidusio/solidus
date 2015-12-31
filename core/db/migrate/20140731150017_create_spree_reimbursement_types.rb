class CreateSolidusReimbursementTypes < ActiveRecord::Migration
  def change
    create_table :solidus_reimbursement_types do |t|
      t.string :name
      t.boolean :active, default: true
      t.boolean :mutable, default: true

      t.timestamps null: true
    end

    reversible do |direction|
      direction.up do
        Solidus::ReimbursementType.create!(name: Solidus::ReimbursementType::ORIGINAL)
      end
    end

    add_column :solidus_return_items, :preferred_reimbursement_type_id, :integer
    add_column :solidus_return_items, :override_reimbursement_type_id, :integer
  end
end
