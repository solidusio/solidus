# frozen_string_literal: true

class RenameApiKeyToSpreeApiKey < ActiveRecord::Migration[4.2]
  def change
    if table_exists?(:spree_users)
      rename_column :spree_users, :api_key, :spree_api_key
    end
  end
end

