class AddBaseCodeToPromotion < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_promotions, :base_code, :string
  end
end
