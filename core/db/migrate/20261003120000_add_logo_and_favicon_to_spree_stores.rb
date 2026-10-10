# frozen_string_literal: true

class AddLogoAndFaviconToSpreeStores < ActiveRecord::Migration[7.0]
  def change
    # The Paperclip columns. Active Storage, the default, keeps its own tables
    # and needs none of these.
    change_table :spree_stores do |t|
      t.string :logo_file_name
      t.string :logo_content_type
      t.integer :logo_file_size
      t.datetime :logo_updated_at
      t.string :favicon_file_name
      t.string :favicon_content_type
      t.integer :favicon_file_size
      t.datetime :favicon_updated_at
    end
  end
end
