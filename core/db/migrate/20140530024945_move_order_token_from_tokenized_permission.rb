class MoveOrderTokenFromTokenizedPermission < ActiveRecord::Migration
  class Solidus::TokenizedPermission < Solidus::Base
    belongs_to :permissable, polymorphic: true
  end

  def up
    case Solidus::Order.connection.adapter_name
    when 'SQLite'
      Solidus::Order.has_one :tokenized_permission, :as => :permissable
      Solidus::Order.includes(:tokenized_permission).each do |o|
        o.update_column :guest_token, o.tokenized_permission.token
      end
    when 'Mysql2', 'MySQL'
      execute "UPDATE spree_orders, spree_tokenized_permissions
               SET spree_orders.guest_token = spree_tokenized_permissions.token
               WHERE spree_tokenized_permissions.permissable_id = spree_orders.id
                  AND spree_tokenized_permissions.permissable_type = 'Solidus::Order'"
    else
      execute "UPDATE spree_orders
               SET guest_token = spree_tokenized_permissions.token
               FROM spree_tokenized_permissions
               WHERE spree_tokenized_permissions.permissable_id = spree_orders.id
                  AND spree_tokenized_permissions.permissable_type = 'Solidus::Order'"
    end
  end

  def down
  end
end
