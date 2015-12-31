class AddMetaTitleToSolidusProducts < ActiveRecord::Migration
  def change
    change_table :solidus_products do |t|
      t.string   :meta_title
    end
  end
end
