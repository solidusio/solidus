class RenamePermalinkToSlugForProducts < ActiveRecord::Migration
  def change
    rename_column :solidus_products, :permalink, :slug
  end
end
