class ImproveStrictnessOfSpreeLineItems < ActiveRecord::Migration[7.0]
  def up
    change_table(:spree_line_items, bulk: true) do |t|
      t.change :variant_id, :integer, null: false
      t.change :order_id, :integer, null: false

      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false

      t.change :adjustment_total, :decimal, precision: 10, scale: 2, default: '0.0', null: false
      t.change :additional_tax_total, :decimal, precision: 10, scale: 2, default: '0.0', null: false
      t.change :promo_total, :decimal, precision: 10, scale: 2, default: '0.0', null: false
    end

    add_foreign_key :spree_line_items, :spree_orders, column: :order_id,
      on_delete: :cascade, on_update: :cascade

    add_foreign_key :spree_line_items, :spree_variants, column: :variant_id,
      on_delete: :restrict, on_update: :cascade

    add_foreign_key :spree_line_items, :spree_tax_categories, column: :tax_category_id,
      on_delete: :restrict, on_update: :cascade
  end

  def down
    remove_foreign_key :spree_line_items, :spree_orders, column: :order_id
    remove_foreign_key :spree_line_items, :spree_variants, column: :variant_id
    remove_foreign_key :spree_line_items, :spree_tax_categories, column: :tax_category_id

    change_table(:spree_line_items, bulk: true) do |t|
      t.change :variant_id, :integer, null: true
      t.change :order_id, :integer, null: true

      t.change :created_at, :datetime, null: true
      t.change :updated_at, :datetime, null: true

      t.change :adjustment_total, :decimal, precision: 10, scale: 2, default: '0.0', null: true
      t.change :additional_tax_total, :decimal, precision: 10, scale: 2, default: '0.0', null: true
      t.change :promo_total, :decimal, precision: 10, scale: 2, default: '0.0', null: true
    end
  end
end
