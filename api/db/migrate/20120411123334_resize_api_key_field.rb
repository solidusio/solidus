# frozen_string_literal: true

class ResizeApiKeyField < ActiveRecord::Migration[4.2]
  def up
    unless defined?(User)
      change_column :spree_users, :api_key, :string, limit: 48
    end
  end
end
