class CreateDefaultStock < ActiveRecord::Migration
  class Variant < ActiveRecord::Base
    self.table_name = 'spree_variants'
  end
  class StockLocation < ActiveRecord::Base
    self.table_name = 'spree_stock_locations'
  end
  class StockItem < ActiveRecord::Base
    self.table_name = 'spree_stock_items'
  end

  def up
    unless column_exists? :spree_stock_locations, :default
      add_column :spree_stock_locations, :default, :boolean, null: false, default: false
    end

    location = StockLocation.create!(name: 'default')

    Spree::Variant.find_each do |variant|
      StockItem.create!(stock_location: location, variant: variant, count_on_hand: variant.count_on_hand)
    end

    remove_column :spree_variants, :count_on_hand
  end
end
