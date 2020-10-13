# frozen_string_literal: true

class AddDiscontinueOnToSpreeProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_products, :discontinue_on, :datetime
  end
end
