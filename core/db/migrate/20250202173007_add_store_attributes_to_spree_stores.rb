class AddStoreAttributesToSpreeStores < ActiveRecord::Migration[7.2]
  def change
    add_column :spree_stores, :legal_name, :string
    add_column :spree_stores, :contact_email, :string
    add_column :spree_stores, :description, :text
    add_column :spree_stores, :vat_id, :string
    add_column :spree_stores, :tax_id, :string
    add_column :spree_stores, :address1, :string
    add_column :spree_stores, :address2, :string
    add_column :spree_stores, :city, :string
    add_column :spree_stores, :zipcode, :string
    add_column :spree_stores, :state_name, :string
    add_column :spree_stores, :contact_phone, :string
    add_column :spree_stores, :country_id, :integer
    add_column :spree_stores, :state_id, :integer
    add_index :spree_stores, :country_id
    add_index :spree_stores, :state_id
  end
end
