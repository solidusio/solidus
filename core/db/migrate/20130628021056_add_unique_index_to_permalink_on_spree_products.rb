class AddUniqueIndexToPermalinkOnSpreeProducts < ActiveRecord::Migration
  def change
    add_index "solidus_products", ["permalink"], :name => "permalink_idx_unique", :unique => true
  end
end
