class AddMetadataToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table Spree.user_class.table_name do |t|
      if t.respond_to?(:jsonb)
        t.jsonb(:customer_metadata, default: {}) unless t.column_exists?(:customer_metadata)
        t.jsonb(:admin_metadata, default: {}) unless t.column_exists?(:admin_metadata)
      else
        t.json(:customer_metadata) unless t.column_exists?(:customer_metadata)
        t.json(:admin_metadata) unless t.column_exists?(:admin_metadata)
      end
    end
  end
end
