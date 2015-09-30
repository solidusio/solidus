class CreateSpreeReturnAuthorizationReasons < ActiveRecord::Migration
  class ReturnAuthorizationReason < ActiveRecord::Base
    self.table_name = 'spree_return_authorization_reasons'
  end

  def change
    create_table :spree_return_authorization_reasons do |t|
      t.string :name
      t.boolean :active, default: true
      t.boolean :mutable, default: true

      t.timestamps null: true
    end

    reversible do |direction|
      direction.up do
        ReturnAuthorizationReason.create!(name: 'Better price available')
        ReturnAuthorizationReason.create!(name: 'Missed estimated delivery date')
        ReturnAuthorizationReason.create!(name: 'Missing parts or accessories')
        ReturnAuthorizationReason.create!(name: 'Damaged/Defective')
        ReturnAuthorizationReason.create!(name: 'Different from what was ordered')
        ReturnAuthorizationReason.create!(name: 'Different from description')
        ReturnAuthorizationReason.create!(name: 'No longer needed/wanted')
        ReturnAuthorizationReason.create!(name: 'Accidental order')
        ReturnAuthorizationReason.create!(name: 'Unauthorized purchase')
      end
    end

    add_column :spree_return_authorizations, :return_authorization_reason_id, :integer
    add_index :spree_return_authorizations, :return_authorization_reason_id, name: 'index_return_authorizations_on_return_authorization_reason_id'
  end
end
