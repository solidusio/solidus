class RemoveOnDemandFromProductAndVariant < ActiveRecord::Migration
  def change
    remove_column :solidus_products, :on_demand
    remove_column :solidus_variants, :on_demand
  end
end
