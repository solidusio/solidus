class AddIndexToUserSolidusApiKey < ActiveRecord::Migration
  def change
    unless defined?(User)
      add_index :solidus_users, :solidus_api_key
    end
  end
end
