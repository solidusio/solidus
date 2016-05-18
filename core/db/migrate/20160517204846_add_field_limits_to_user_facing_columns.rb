class AddFieldLimitsToUserFacingColumns < ActiveRecord::Migration
  def change
		## friendly_id_slugs
		change_column :friendly_id_slugs, :slug, :string, limit: 255

		## spree_addresses
		change_column :spree_addresses, :firstname, :string, limit: 100
		change_column :spree_addresses, :lastname, :string, limit: 100
		change_column :spree_addresses, :address1, :string, limit: 255
		change_column :spree_addresses, :address2, :string, limit: 255
		change_column :spree_addresses, :city, :string, limit: 255
		change_column :spree_addresses, :zipcode, :string, limit: 255
		change_column :spree_addresses, :state_name, :string, limit: 255
		change_column :spree_addresses, :company, :string, limit: 255
		change_column :spree_addresses, :phone, :string, limit: 100
		change_column :spree_addresses, :alternative_phone, :string, limit: 100

		## spree_orders
		change_column :spree_orders, :email, :string, limit: 255

		## spree_products
		change_column :spree_products, :name, :string, limit: 255
		change_column :spree_products, :slug, :string, limit: 255
		change_column :spree_products, :meta_keywords, :string, limit: 255
		change_column :spree_products, :meta_title, :string, limit: 255

		## spree_promotions
		change_column :spree_promotions, :name, :string, limit: 255
		change_column :spree_promotions, :description, :string, limit: 500
		change_column :spree_promotions, :code, :string, limit: 255
		change_column :spree_promotions, :code, :string, limit: 255

		## spree_refund_reasons
		change_column :spree_refund_reasons, :name, :string, limit: 255
		change_column :spree_refund_reasons, :code, :string, limit: 255

		## spree_shipments
		change_column :spree_shipments, :tracking, :string, limit: 255

		## spree_shipping_methods
		change_column :spree_shipping_methods, :name, :string, limit: 255
		change_column :spree_shipping_methods, :admin_name, :string, limit: 255
		change_column :spree_shipping_methods, :tracking_url, :string, limit: 255
		change_column :spree_shipping_methods, :code, :string, limit: 255

		## spree_stock_locations
		change_column :spree_stock_locations, :name, :string, limit: 255
		change_column :spree_stock_locations, :address1, :string, limit: 255
		change_column :spree_stock_locations, :address2, :string, limit: 255
		change_column :spree_stock_locations, :city, :string, limit: 255
		change_column :spree_stock_locations, :state_name, :string, limit: 255
		change_column :spree_stock_locations, :zipcode, :string, limit: 255
		change_column :spree_stock_locations, :phone, :string, limit: 255
		change_column :spree_stock_locations, :code, :string, limit: 255

		## spree_stock_transfers
		change_column :spree_stock_transfers, :description, :string, limit: 500
		change_column :spree_stock_transfers, :tracking_number, :string, limit: 255

		## spree_store_credit_categories
		change_column :spree_store_credit_categories, :name, :string, limit: 255

		## spree_store_credit_types
		change_column :spree_store_credit_types, :name, :string, limit: 255

		## spree_store_credit_update_reasons
		change_column :spree_store_credit_update_reasons, :name, :string, limit: 255

		## spree_stores
		change_column :spree_stores, :name, :string, limit: 255
		change_column :spree_stores, :url, :string, limit: 255
		change_column :spree_stores, :seo_title, :string, limit: 255
		change_column :spree_stores, :code, :string, limit: 255

		## spree_tax_categories
		change_column :spree_tax_categories, :name, :string, limit: 255
		change_column :spree_tax_categories, :description, :string, limit: 255
		change_column :spree_tax_categories, :tax_code, :string, limit: 255

		## spree_taxonomies
		change_column :spree_taxonomies, :name, :string, limit: 255

		## spree_taxons
		change_column :spree_taxons, :name, :string, limit: 255
		change_column :spree_taxons, :permalink, :string, limit: 255
		change_column :spree_taxons, :meta_title, :string, limit: 255
		change_column :spree_taxons, :meta_description, :string, limit: 255
		change_column :spree_taxons, :meta_keywords, :string, limit: 255

		## spree_taxons
		change_column :spree_users, :email, :string, limit: 255
		change_column :spree_users, :login, :string, limit: 255

		## spree_variants
		change_column :spree_variants, :sku, :string, limit: 255

		## spree_zones
		change_column :spree_zones, :name, :string, limit: 255
		change_column :spree_zones, :description, :string, limit: 255
  end
end
