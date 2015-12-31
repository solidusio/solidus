class ChangeMetaDescriptionOnSolidusProductsToText < ActiveRecord::Migration
  def change
    change_column :solidus_products, :meta_description, :text, :limit => nil
  end
end
