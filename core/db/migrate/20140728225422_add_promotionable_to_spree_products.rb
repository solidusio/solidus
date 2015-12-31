class AddPromotionableToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :solidus_products, :promotionable, :boolean, default: true
  end
end
