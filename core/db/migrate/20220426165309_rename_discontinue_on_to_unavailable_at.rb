class RenameDiscontinueOnToUnavailableAt < ActiveRecord::Migration[5.2]
  def change
    rename_column :spree_products, :discontinue_on, :available_until
  end
end
