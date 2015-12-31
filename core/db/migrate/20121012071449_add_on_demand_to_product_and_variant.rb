class AddOnDemandToProductAndVariant < ActiveRecord::Migration
  def change
  	add_column :solidus_products, :on_demand, :boolean, :default => false
  	add_column :solidus_variants, :on_demand, :boolean, :default => false
  end
end
