class AddApiKeyToSolidusUsers < ActiveRecord::Migration
  def change
    unless defined?(User)
      add_column :solidus_users, :api_key, :string, :limit => 40
    end
  end
end
