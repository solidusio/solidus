class CreateSolidusStores < ActiveRecord::Migration
  def change
    if table_exists?(:solidus_stores)
      rename_column :solidus_stores, :domains, :url
      rename_column :solidus_stores, :email, :mail_from_address
      add_column :solidus_stores, :meta_description, :text
      add_column :solidus_stores, :meta_keywords, :text
      add_column :solidus_stores, :seo_title, :string
    else
      create_table :solidus_stores do |t|
        t.string :name
        t.string :url
        t.text :meta_description
        t.text :meta_keywords
        t.string :seo_title
        t.string :mail_from_address
        t.string :default_currency
        t.string :code
        t.boolean :default, default: false, null: false

        t.timestamps null: true
      end
    end
  end
end
