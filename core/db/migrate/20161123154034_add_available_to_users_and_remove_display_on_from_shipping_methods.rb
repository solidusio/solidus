# frozen_string_literal: true

class AddAvailableToUsersAndRemoveDisplayOnFromShippingMethods < ActiveRecord::Migration[5.0]
  def up
    add_column(:spree_shipping_methods, :available_to_users, :boolean, default: true)
    execute("UPDATE spree_shipping_methods "\
             "SET available_to_users=#{quoted_false} "\
             "WHERE display_on='back_end'")
    remove_column(:spree_shipping_methods, :display_on)
  end

  def down
    add_column(:spree_shipping_methods, :display_on, :string)
    execute("UPDATE spree_shipping_methods "\
            "SET display_on='both' "\
            "WHERE (available_to_users=#{quoted_true})")
    execute("UPDATE spree_shipping_methods "\
            "SET display_on='back_end' "\
            "WHERE (available_to_users=#{quoted_false})")
    remove_column(:spree_shipping_methods, :available_to_users)
  end
end
