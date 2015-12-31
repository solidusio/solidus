class CreateShippingMethodCategories < ActiveRecord::Migration
  def change
    create_table :solidus_shipping_method_categories do |t|
      t.integer :shipping_method_id, :null => false
      t.integer :shipping_category_id, :null => false

      t.timestamps null: true
    end

    add_index :solidus_shipping_method_categories, :shipping_method_id
    add_index :solidus_shipping_method_categories, :shipping_category_id
  end
end
