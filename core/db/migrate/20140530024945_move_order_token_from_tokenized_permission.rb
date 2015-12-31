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
      execute "UPDATE solidus_orders, solidus_tokenized_permissions
               SET solidus_orders.guest_token = solidus_tokenized_permissions.token
               WHERE solidus_tokenized_permissions.permissable_id = solidus_orders.id
                  AND solidus_tokenized_permissions.permissable_type = 'Solidus::Order'"
    else
      execute "UPDATE solidus_orders
               SET guest_token = solidus_tokenized_permissions.token
               FROM solidus_tokenized_permissions
               WHERE solidus_tokenized_permissions.permissable_id = solidus_orders.id
                  AND solidus_tokenized_permissions.permissable_type = 'Solidus::Order'"
    end
  end

  def down
  end
end
