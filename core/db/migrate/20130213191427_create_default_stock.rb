class CreateDefaultStock < ActiveRecord::Migration
  def up
    unless column_exists? :solidus_stock_locations, :default
      add_column :solidus_stock_locations, :default, :boolean, null: false, default: false
    end

    Solidus::StockLocation.skip_callback(:create, :after, :create_stock_items)
    Solidus::StockLocation.skip_callback(:save, :after, :ensure_one_default)
    Solidus::StockItem.skip_callback(:save, :after, :process_backorders)
    location = Solidus::StockLocation.new(name: 'default')
    location.save(validate: false)

    Solidus::Variant.find_each do |variant|
      stock_item = Solidus::StockItem.unscoped.build(stock_location: location, variant: variant)
      stock_item.send(:count_on_hand=, variant.count_on_hand)
      # Avoid running default_scope defined by acts_as_paranoid, related to #3805,
      # validations would run a query with a delete_at column that might not be present yet
      stock_item.save! validate: false
    end

    remove_column :solidus_variants, :count_on_hand
  end

  def down
    add_column :solidus_variants, :count_on_hand, :integer

    Solidus::StockItem.find_each do |stock_item|
      stock_item.variant.update_column :count_on_hand, stock_item.count_on_hand
    end

    Solidus::StockLocation.delete_all
    Solidus::StockItem.delete_all
  end
end
