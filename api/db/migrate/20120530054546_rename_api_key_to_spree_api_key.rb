class RenameApiKeyToSolidusApiKey < ActiveRecord::Migration
  def change
    unless defined?(User)
      rename_column :solidus_users, :api_key, :solidus_api_key
    end
  end
end
